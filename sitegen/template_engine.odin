package sitegen

import "core:log"
import "core:strings"

Context :: map[string]string

Expr :: string

ParsingState :: enum {
    Copying,
    MaybeExpressionOrCommand,
    Expression,
}

eval_expr :: proc(expr: Expr, ctx: Context) -> string {
    if expr in ctx {
        return ctx[expr]
    }
    return ""
}

read_expr :: proc(templ_str: string) -> (expr: Expr) {
    return "TODO"
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
    // TODO: is this correct?? why do we need reader.i -1 here ??
    result := reader.s[reader.i - 1:reader.i + i64(found)]
    strings.reader_seek(reader, i64(found + len(sentinel)), .Current)
    return result, true
}

render_template :: proc(templ_str: string, ctx: Context) -> string {
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
            if expr_read, ok := read_until(&reader, "}}"); ok {
                expr_read = strings.trim(expr_read, " ")
                log.infof("expr_read: [%s]", expr_read)
                strings.write_string(&builder, eval_expr(expr_read, ctx))
                state = .Copying
            } else {
                return "ERROR PARSING TEMPLATE"
            }
        }
    }

    return strings.to_string(builder)
}
