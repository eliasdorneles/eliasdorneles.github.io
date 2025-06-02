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
    MaybeExpressionOrCommand,
    Expression,
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
        // here we implement date formatting for datetime values represented in
        // iso format
        if path[0] == "isoformat()" {
            return v
        } else if path[0] == "strftime(\"%Y, %B %d\")" {
            ts, utc_offset, _ := time.iso8601_to_time_and_offset(v)
            // TODO: how to free this?? maybe learn how to use the temp allocator
            return fmt.aprintf(
                "%d, %s %02d",
                time.year(ts),
                time.month(ts),
                time.day(ts),
            )
        }
        return nil // can't do lookups in strings
    case Context:
        if len(path) == 1 {
            return v[path[0]]
        } else {
            next_val := v[path[0]]
            return eval_context_path(&next_val, path[1:])
        }
    }
    return "ERROR"
}

eval_expr :: proc(expr: Expr, ctx: ^Context) -> Value {
    path := strings.split(expr, ".")
    defer delete(path)

    v: Value = ctx^
    return eval_context_path(&v, path)
}

// input reading helpers:
skip_spaces :: proc(reader: ^strings.Reader) {
    r, _, err := strings.reader_read_rune(reader)
    for r == ' ' && err == nil {
        r, _, err = strings.reader_read_rune(reader)
    }
    if r != ' ' && err == nil {
        strings.reader_unread_rune(reader)
    }
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

    for char, size, read_err := strings.reader_read_rune(&reader);
        read_err == nil;
        char, size, read_err = strings.reader_read_rune(&reader) {
        switch state {
        case .Copying:
            if char == '{' {
                state = .MaybeExpressionOrCommand
            } else {
                strings.write_rune(&builder, char)
            }
        case .MaybeExpressionOrCommand:
            if char == '{' {     // handle {{ case
                state = .Expression
            } else {
                state = .Copying
                strings.write_rune(&builder, '{')
            }
        // TODO: handle {% case
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
        }
    }

    return strings.to_string(builder)
}
