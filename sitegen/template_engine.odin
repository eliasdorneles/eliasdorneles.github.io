package sitegen

import "core:bytes"
import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:time"

TEMPLATE_DIR :: "mytheme/templates/"

Environment :: struct {
    raw_templates:    map[string]string,
    loaded_templates: map[string]string,
}

LoadingState :: enum {
    Copying,
    Skipping,
    MaybeStatement,
    Statement,
}

ParsingState :: enum {
    Copying,
    Skipping,
    MaybeExpressionOrCommand,
    Expression,
    Command,
}

destroy_env :: proc(env: ^Environment) {
    delete(env.raw_templates)
    delete(env.loaded_templates)
}

to_string :: proc(value: json.Value) -> string {
    if value == nil {
        return ""
    }
    #partial switch v in value {
    case json.Null:
        return ""
    case json.String:
        return v
    case json.Object:
        repr := v["__repr__"]
        if repr != nil {
            return to_string(repr)
        }
    }
    if json_str, err := json.marshal(value, allocator = context.temp_allocator);
       err == nil {
        return string(json_str)
    }
    return "ERROR"
}

clone_context :: proc(src_ctx: json.Object) -> json.Object {
    ctx := make(json.Object)
    for key, val in src_ctx {
        ctx[key] = val
    }
    return ctx
}

// ({"um": "1"}, ["um"]) -> "1"
// ({"um": "1"}, ["dois"]) -> nil
// ({"um": "1"}, ["um", "dois"]) -> nil
// ({"um": {"dois": "2"}}, ["um", "dois"]) -> "2"
// ({"list": ["1", "2"]}, ["list"]) -> ["1", "2"]
eval_context_path :: proc(value: ^json.Value, path: []string) -> json.Value {
    if value == nil || value^ == nil {
        return nil
    }
    #partial switch &v in value^ {
    case json.Null:
        return nil
    case json.String:
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
    case json.Object:
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
    case json.Array:
        return nil // can't do lookups in lists yet
    }
    return "ERROR, UNSUPPORTED TYPE LOOKUP"
}

eval_expr :: proc(expr: string, ctx: ^json.Object) -> json.Value {
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

    v: json.Value = ctx^
    return eval_context_path(&v, path)
}

eql_values :: proc(val1: json.Value, val2: json.Value) -> bool {
    val1_bytes, _ := json.marshal(val1, allocator = context.temp_allocator)
    val2_bytes, _ := json.marshal(val2, allocator = context.temp_allocator)
    return bytes.compare(val1_bytes, val2_bytes) == 0
}

eval_condition :: proc(token_list: []string, ctx: ^json.Object) -> bool {
    if len(token_list) == 1 {
        cond_expr_val := eval_expr(token_list[0], ctx)
        if cond_expr_val == nil {
            return false
        }
        switch v in cond_expr_val {
        case json.Null:
            return false
        case json.Float:
            return v != 0
        case json.Integer:
            return v != 0
        case json.Boolean:
            return v
        case json.String:
            return len(v) > 0
        case json.Object:
            return true
        case json.Array:
            return len(v) > 0
        }
    } else if len(token_list) == 3 {
        op1, operator, op2 := token_list[0], token_list[1], token_list[2]
        if operator == "is" && op2 == "defined" {
            return ctx[op1] != nil
        } else if operator == "==" {
            return eql_values(eval_expr(op1, ctx), eval_expr(op2, ctx))
        } else if operator == "!=" {
            return !eql_values(eval_expr(op1, ctx), eval_expr(op2, ctx))
        }
    } else if len(token_list) == 7 && token_list[3] == "and" {
        return eval_condition(token_list[:3], ctx) && eval_condition(token_list[4:], ctx)
    }
    // TODO: handle more complex expressions
    log.info("Condition not yet supported:", token_list)
    return false
}

// read_until(reader for "one two three", "three") -> "one two ", true
read_until :: proc(reader: ^strings.Reader, sentinel: string) -> (string, bool) {
    // advance reader until the sentinel string, return a slice of the string
    // until just before the sentinel
    found := strings.index(reader.s[reader.i:], sentinel)
    if found == -1 {
        return "", false
    }
    result := reader.s[reader.i:reader.i + i64(found)]
    strings.reader_seek(reader, i64(found + len(sentinel)), .Current)
    return result, true
}

read_until_next_stmt :: proc(reader: ^strings.Reader) -> (string, bool) {
    if templ_read, ok := read_until(reader, "{%"); ok {
        if expr_read, ok := read_until(reader, "%}"); ok {
            return strings.trim(expr_read, " "), true
        }
        // if we couldn't find the end of the expression, let's put back the "{%"
        // we read at first
        strings.reader_unread_rune(reader) // %
        strings.reader_unread_rune(reader) // {
        return "", false
    }
    return "", false
}

parse_inner_for_template_str :: proc(reader: ^strings.Reader) -> (string, bool) {
    start_index := reader.i

    ok: bool
    next_stmt: string
    next_stmt, ok = read_until_next_stmt(reader)
    for ok {
        if next_stmt == "for" {
            // we'll parse discarding the output for now, let the main loop
            // of the recursive render_template call to parse it again
            _, ok := parse_inner_for_template_str(reader)
            if !ok {
                return "", false
            }
        }
        if next_stmt == "endfor" {
            return reader.s[start_index:reader.i], true
        }
        next_stmt, ok = read_until_next_stmt(reader)
    }

    return "", false
}

render_for_loop :: proc(
    builder: ^strings.Builder,
    loop_list: json.Array,
    loop_var: string,
    loop_inner_templ_str: string,
    ctx: ^json.Object,
) {
    // for each item of the iterable value ...
    for item in loop_list {
        // we create its context object...
        loop_iter_ctx := clone_context(ctx^)
        loop_iter_ctx[loop_var] = item
        defer delete(loop_iter_ctx)

        // render the inner loop template with it...
        inner_render := render_template(loop_inner_templ_str, &loop_iter_ctx)

        // and send to the output!
        written := strings.write_string(builder, inner_render)
        if written != len(inner_render) {
            log.error(
                "ERROR: couldn't write to the builder buffer -- not enough memory?",
            )
        }
    }
}

render_template :: proc(templ_str: string, ctx: ^json.Object) -> string {
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
                return "ERROR PARSING TEMPLATE EXPRESSION"
            }
        case .Command:
            // unread current rune, let read_until + trim do all the work ;)
            strings.reader_unread_rune(&reader)

            if stmt_read, ok := read_until(&reader, "%}"); ok {
                stmt_read := strings.trim_space(stmt_read)
                stmt_split := strings.split(stmt_read, " ")
                defer delete(stmt_split)
                if stmt_split[0] == "if" {
                    cond_val := eval_condition(stmt_split[1:], ctx)
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
                } else if stmt_split[0] == "for" {
                    // we handle the for loop by fetching the inner template inside it...
                    if inner_templ, ok := parse_inner_for_template_str(&reader); ok {
                        loop_var := stmt_split[1]
                        // ... evaluate the iterable expression
                        loop_iterable := eval_expr(stmt_split[3], ctx)
                        #partial switch v in loop_iterable {
                        case json.Array:
                            // ... and rendering the inner template for each iterable item
                            render_for_loop(&builder, v, loop_var, inner_templ, ctx)
                        case:
                            log.error("Trying to loop over non-list at:", stmt_read)
                            return "ERROR LOOPING OVER NON-LIST"
                        }
                    } else {
                        log.error("Error parsing for-loop", stmt_read)
                        return "ERROR PARSING FOR LOOP"
                    }
                    state = .Copying
                } else {
                    // handle {% endfor %} and other unknown commands by
                    // switching back to regular copying mode
                    state = .Copying
                }
            } else {
                // log.error(
                //     "Error parsing template at:",
                //     reader.s[max(reader.i - 12, 0):reader.i],
                //     reader.i,
                //     "state:",
                //     state,
                // )
                return "ERROR PARSING TEMPLATE"
            }

        }
    }

    return strings.clone_from(
        strings.to_string(builder),
        allocator = context.temp_allocator,
    )
}

resolve_template_blocks :: proc(env: ^Environment, template_name: string) -> (string, bool) {
    return "", false
}


load_template :: proc(env: ^Environment, template_name: string) -> bool {
    if template_name not_in env.raw_templates {
        // template not found
        return false
    }

    builder: strings.Builder
    defer strings.builder_destroy(&builder)

    state: LoadingState
    reader: strings.Reader
    strings.reader_init(&reader, env.raw_templates[template_name])

    for char, size, read_err := strings.reader_read_rune(&reader);
        read_err == nil;
        char, size, read_err = strings.reader_read_rune(&reader) {
        switch state {
        case .Skipping:
            if char == '{' {
                state = .MaybeStatement
            }
        case .Copying:
            if char == '{' {
                state = .MaybeStatement
            } else {
                strings.write_rune(&builder, char)
            }
        case .MaybeStatement:
            if char == '%' {
                state = .Statement
            } else {
                state = .Copying
                strings.write_rune(&builder, '{')
                strings.write_rune(&builder, char)
            }
        case .Statement:
            state = .Copying
            // unread current rune, let read_until + trim do all the work ;)
            strings.reader_unread_rune(&reader)

            before_index := reader.i
            if stmt_read, ok := read_until(&reader, "%}"); ok {
                stmt_read := strings.trim_space(stmt_read)
                stmt_split := strings.split(stmt_read, " ")
                defer delete(stmt_split)

                if stmt_split[0] == "include" {
                    if len(stmt_split) != 2 {
                        // "ERROR INCLUDING TEMPLATE -- too many params"
                        return false
                    }
                    to_include := strings.trim(stmt_split[1], `"`)
                    if to_include not_in env.raw_templates {
                        // "ERROR INCLUDING TEMPLATE -- NOT FOUND"
                        return false
                    }
                    load_template(env, to_include) or_return
                    strings.write_string(&builder, env.loaded_templates[to_include])
                    state = .Copying
                } else {
                    strings.write_string(&builder, "{% ")
                    strings.write_string(&builder, stmt_read)
                    strings.write_string(&builder, " %}")
                    state = .Copying
                }
            } else {
                // error when parsing statements
                return false
            }
        }
    }
    env.loaded_templates[template_name] = strings.clone_from(
        strings.to_string(builder),
        allocator = context.temp_allocator,
    )
    return true
}
