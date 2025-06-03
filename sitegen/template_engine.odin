package sitegen

import "core:fmt"
import "core:log"
import "core:strings"
import "core:time"

Context :: distinct map[string]Value

Value :: union {
    string,
    Context,
}

Expr :: string

ParsingState :: enum {
    Copying,
    Skipping,
    MaybeExpressionOrCommand,
    Expression,
    Command,
}

to_string :: proc(value: Value) -> string {
    switch v in value {
    case nil:
        return ""
    case string:
        return v
    case Context:
        // TODO: consider building a repr of the object here
        return "(object)"
    }
    return ""
}

// eval_context_path({"um": "1"}, ["um"]) -> "1"
// eval_context_path({"um": "1"}, ["dois"]) -> nil
// eval_context_path({"um": "1"}, ["um", "dois"]) -> nil
// eval_context_path({"um": {"dois": "2"}}, ["um", "dois"]) -> "2"
eval_context_path :: proc(value: ^Value, path: []string) -> Value {
    if value == nil || value^ == nil {
        return nil
    }
    switch &v in value^ {
    case nil:
        return nil
    case string:
        // here we implement date formatting for datetime values represented as
        // strings in iso format
        if path[0] == "isoformat()" {
            return v
        } else if path[0] == "strftime(\"%Y, %B %d\")" {
            ts, utc_offset, _ := time.iso8601_to_time_and_offset(v)
            return fmt.aprintf(
                "%d, %s %02d",
                time.year(ts),
                time.month(ts),
                time.day(ts),
                allocator = context.temp_allocator,
            )
        }
        return nil // can't do lookups in strings
    case Context:
        if len(path) == 1 {
            key: string = path[0]
            // ignoring |striptags because none of my articles have tags in the title
            if strings.ends_with(key, "|striptags") {
                key = key[:len(key) - len("|striptags")]
            }
            return v[key]
        } else {
            next_val := v[path[0]]
            return eval_context_path(&next_val, path[1:])
        }
    }
    return "ERROR"
}

eval_expr :: proc(expr: Expr, ctx: ^Context) -> Value {
    // handle special case {{ lang_display_name(translation.lang) }}
    if strings.starts_with(expr, "lang_display_name(") {
        lang := eval_expr(expr[len("lang_display_name("):len(expr) - 1], ctx)
        #partial switch v in lang {
        case string:
            if v == "en" {
                return "English"
            } else if v == "pt-br" {
                return "Português (Brasil)"
            }
            return v
        }
    }

    path := strings.split(expr, ".")
    defer delete(path)

    v: Value = ctx^
    return eval_context_path(&v, path)
}

read_until :: proc(reader: ^strings.Reader, sentinel: string) -> (string, bool) {
    found := strings.index_any(reader.s[reader.i:], sentinel)
    if found == -1 {
        return "", false
    }
    result := reader.s[reader.i:reader.i + i64(found)]
    strings.reader_seek(reader, i64(found + len(sentinel)), .Current)
    return result, true
}

render_template :: proc(templ_str: string, ctx: ^Context) -> string {
    builder: strings.Builder
    defer strings.builder_destroy(&builder)

    state: ParsingState
    reader: strings.Reader
    strings.reader_init(&reader, templ_str)

    if_cond_stack: [dynamic]bool
    defer delete(if_cond_stack)

    for char, size, read_err := strings.reader_read_rune(&reader);
        read_err == nil;
        char, size, read_err = strings.reader_read_rune(&reader) {
        switch state {
        case .Skipping:
            if char == '{' {
                state = .MaybeExpressionOrCommand
            }
        case .Copying:
            if char == '{' {
                state = .MaybeExpressionOrCommand
            } else {
                strings.write_rune(&builder, char)
            }
        case .MaybeExpressionOrCommand:
            if char == '{' {     // handle {{ case
                state = .Expression
            } else if char == '%' {
                state = .Command
            } else {
                state = .Copying
                strings.write_rune(&builder, '{')
            }
        case .Expression:
            // unread current rune, let read_until + trim do all the work ;)
            strings.reader_unread_rune(&reader)

            if expr_read, ok := read_until(&reader, "}}"); ok {
                expr_read = strings.trim(expr_read, " ")
                // log.infof("expr_read: [%s]", expr_read)
                strings.write_string(&builder, to_string(eval_expr(expr_read, ctx)))
                state = .Copying
            } else {
                return "ERROR PARSING TEMPLATE"
            }
        case .Command:
            // unread current rune, let read_until + trim do all the work ;)
            strings.reader_unread_rune(&reader)

            if stmt_read, ok := read_until(&reader, "%}"); ok {
                stmt_read := strings.trim(stmt_read, " ")
                stmt_split := strings.split(stmt_read, " ")
                defer delete(stmt_split)
                // log.info("stmt_split:", stmt_split)
                if stmt_split[0] == "if" {
                    // TODO: handle more complex expressions
                    cond_expr_val := eval_expr(stmt_split[1], ctx)
                    cond_val: bool
                    switch v in cond_expr_val {
                    case nil:
                        cond_val = false
                    case string:
                        cond_val = len(v) > 0
                    case Context:
                        cond_val = true
                    }
                    append(&if_cond_stack, cond_val)
                    if cond_val {
                        state = .Copying
                    } else {
                        state = .Skipping
                    }
                } else if stmt_split[0] == "else" {
                    if pop(&if_cond_stack) {
                        state = .Skipping
                    } else {
                        state = .Copying
                    }
                } else {
                    state = .Copying
                }
            } else {
                return "ERROR PARSING TEMPLATE"
            }

        }
    }

    return strings.to_string(builder)
}
