package sitegen

import "core:bytes"
import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"
import "core:time"

TEMPLATE_DIR :: "mytheme/templates/"

Environment :: struct {
    raw_templates:    map[string]string, // raw template text as-is on disk
    loaded_templates: map[string]string, // templates with resolved includes
}

ParsingStatementsState :: enum {
    Copying,
    Skipping,
    MaybeStatement,
    Statement,
}


destroy_env :: proc(env: ^Environment) {
    delete(env.raw_templates)
    delete(env.loaded_templates)
}

// New tokenizer-based parser implementation
TokenType :: enum {
    TEXT, // Plain text content
    EXPRESSION, // {{ variable }}
    STATEMENT, // {% if/for/block %}
    EOF, // End of file
}

Token :: struct {
    type:      TokenType,
    value:     string,
    line:      int,
    column:    int,
    start_pos: int,
    end_pos:   int,
}

Tokenizer :: struct {
    input:  string,
    pos:    int,
    line:   int,
    column: int,
}

// Expression AST System
ExprNode :: union {
    Variable,
    PropertyAccess,
    FunctionCall,
    FilterExpression,
    BinaryOp,
    Literal,
}

Variable :: struct {
    name: string,
}

PropertyAccess :: struct {
    object:   ^ExprNode,
    property: string,
}

FunctionCall :: struct {
    name: string,
    args: []ExprNode,
}

FilterExpression :: struct {
    expr:        ^ExprNode,
    filter_name: string,
}

BinaryOp :: struct {
    left:     ^ExprNode,
    operator: string, // "==", "!=", "and", "is", etc.
    right:    ^ExprNode,
}

Literal :: struct {
    value: json.Value,
}

// Expression tokenizer for parsing individual expressions
ExprTokenType :: enum {
    IDENTIFIER, // variable names, function names
    DOT, // .
    PIPE, // |
    LPAREN, // (
    RPAREN, // )
    STRING, // "quoted string"
    EQUALS, // ==
    NOT_EQUALS, // !=
    AND, // and
    IS, // is
    DEFINED, // defined
    EXPR_EOF, // end of expression
}

ExprToken :: struct {
    type:  ExprTokenType,
    value: string,
    pos:   int,
}

ExprTokenizer :: struct {
    input: string,
    pos:   int,
}

// Expression Parser
ExprParser :: struct {
    tokenizer:     ExprTokenizer,
    current_token: ExprToken,
}

// Expression tokenizer functions
init_expr_tokenizer :: proc(input: string) -> ExprTokenizer {
    return ExprTokenizer{input = input, pos = 0}
}

peek_expr_char :: proc(tokenizer: ^ExprTokenizer, offset: int = 0) -> u8 {
    pos := tokenizer.pos + offset
    if pos >= len(tokenizer.input) {
        return 0
    }
    return tokenizer.input[pos]
}

advance_expr_char :: proc(tokenizer: ^ExprTokenizer) -> u8 {
    if tokenizer.pos >= len(tokenizer.input) {
        return 0
    }
    char := tokenizer.input[tokenizer.pos]
    tokenizer.pos += 1
    return char
}

skip_expr_whitespace :: proc(tokenizer: ^ExprTokenizer) {
    for tokenizer.pos < len(tokenizer.input) {
        char := peek_expr_char(tokenizer)
        if char == ' ' || char == '\t' || char == '\n' || char == '\r' {
            advance_expr_char(tokenizer)
        } else {
            break
        }
    }
}

next_expr_token :: proc(tokenizer: ^ExprTokenizer) -> ExprToken {
    skip_expr_whitespace(tokenizer)

    if tokenizer.pos >= len(tokenizer.input) {
        return ExprToken{type = .EXPR_EOF, value = "", pos = tokenizer.pos}
    }

    start_pos := tokenizer.pos
    char := peek_expr_char(tokenizer)

    switch char {
    case '.':
        advance_expr_char(tokenizer)
        return ExprToken{type = .DOT, value = ".", pos = start_pos}
    case '|':
        advance_expr_char(tokenizer)
        return ExprToken{type = .PIPE, value = "|", pos = start_pos}
    case '(':
        advance_expr_char(tokenizer)
        return ExprToken{type = .LPAREN, value = "(", pos = start_pos}
    case ')':
        advance_expr_char(tokenizer)
        return ExprToken{type = .RPAREN, value = ")", pos = start_pos}
    case '"':
        advance_expr_char(tokenizer) // skip opening quote
        value_start := tokenizer.pos
        for tokenizer.pos < len(tokenizer.input) && peek_expr_char(tokenizer) != '"' {
            advance_expr_char(tokenizer)
        }
        value := tokenizer.input[value_start:tokenizer.pos]
        if tokenizer.pos < len(tokenizer.input) {
            advance_expr_char(tokenizer) // skip closing quote
        }
        return ExprToken{type = .STRING, value = value, pos = start_pos}
    case '!':
        if peek_expr_char(tokenizer, 1) == '=' {
            advance_expr_char(tokenizer)
            advance_expr_char(tokenizer)
            return ExprToken{type = .NOT_EQUALS, value = "!=", pos = start_pos}
        }
    case '=':
        if peek_expr_char(tokenizer, 1) == '=' {
            advance_expr_char(tokenizer)
            advance_expr_char(tokenizer)
            return ExprToken{type = .EQUALS, value = "==", pos = start_pos}
        }
    }

    // Handle identifiers and keywords
    if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z') || char == '_' {
        for tokenizer.pos < len(tokenizer.input) {
            c := peek_expr_char(tokenizer)
            if (c >= 'a' && c <= 'z') ||
               (c >= 'A' && c <= 'Z') ||
               (c >= '0' && c <= '9') ||
               c == '_' {
                advance_expr_char(tokenizer)
            } else {
                break
            }
        }
        value := tokenizer.input[start_pos:tokenizer.pos]

        // Check for keywords
        switch value {
        case "and":
            return ExprToken{type = .AND, value = value, pos = start_pos}
        case "is":
            return ExprToken{type = .IS, value = value, pos = start_pos}
        case "defined":
            return ExprToken{type = .DEFINED, value = value, pos = start_pos}
        case:
            return ExprToken{type = .IDENTIFIER, value = value, pos = start_pos}
        }
    }

    // Unknown character, skip it
    advance_expr_char(tokenizer)
    return next_expr_token(tokenizer)
}

// Expression parser functions
init_expr_parser :: proc(input: string) -> ExprParser {
    tokenizer := init_expr_tokenizer(input)
    parser := ExprParser {
        tokenizer = tokenizer,
    }
    parser.current_token = next_expr_token(&parser.tokenizer)
    return parser
}

expect_token :: proc(parser: ^ExprParser, token_type: ExprTokenType) -> bool {
    return parser.current_token.type == token_type
}

consume_token :: proc(parser: ^ExprParser) {
    parser.current_token = next_expr_token(&parser.tokenizer)
}

parse_primary :: proc(parser: ^ExprParser) -> ^ExprNode {
    #partial switch parser.current_token.type {
    case .IDENTIFIER:
        name := parser.current_token.value
        consume_token(parser)

        // Check for function call
        if expect_token(parser, .LPAREN) {
            consume_token(parser) // consume '('

            args: [dynamic]ExprNode
            // Parse function arguments
            if !expect_token(parser, .RPAREN) {
                arg := parse_logical(parser)
                if arg != nil {
                    append(&args, arg^)
                }

                // For now, assume single argument
                for !expect_token(parser, .RPAREN) && !expect_token(parser, .EXPR_EOF) {
                    consume_token(parser)
                }
            }

            if expect_token(parser, .RPAREN) {
                consume_token(parser) // consume ')'
            }

            node := new(ExprNode)
            node^ = FunctionCall {
                name = name,
                args = args[:],
            }
            return node
        }

        // Regular variable
        node := new(ExprNode)
        node^ = Variable {
            name = name,
        }
        return node

    case .STRING:
        value := parser.current_token.value
        consume_token(parser)
        node := new(ExprNode)
        node^ = Literal {
            value = json.String(value),
        }
        return node
    }

    return nil
}

parse_postfix :: proc(parser: ^ExprParser) -> ^ExprNode {
    left := parse_primary(parser)
    if left == nil {
        return nil
    }

    for {
        if expect_token(parser, .DOT) {
            consume_token(parser) // consume '.'
            if expect_token(parser, .IDENTIFIER) {
                property := parser.current_token.value
                consume_token(parser)

                // Check if this is a method call like isoformat()
                if expect_token(parser, .LPAREN) {
                    consume_token(parser) // consume '('
                    if expect_token(parser, .RPAREN) {
                        consume_token(parser) // consume ')'
                        property = strings.concatenate(
                            {property, "()"},
                            allocator = context.temp_allocator,
                        )
                    } else {
                        // Handle method calls with arguments like strftime("format")
                        arg_tokens: [dynamic]string
                        defer delete(arg_tokens)

                        for !expect_token(parser, .RPAREN) &&
                            !expect_token(parser, .EXPR_EOF) {
                            if expect_token(parser, .STRING) {
                                token_str := strings.concatenate(
                                    {"\"", parser.current_token.value, "\""},
                                    allocator = context.temp_allocator,
                                )
                                append(&arg_tokens, token_str)
                            } else {
                                append(&arg_tokens, parser.current_token.value)
                            }
                            consume_token(parser)
                        }
                        if expect_token(parser, .RPAREN) {
                            consume_token(parser)
                        }

                        // Reconstruct the method call with arguments
                        args_str := strings.join(
                            arg_tokens[:],
                            "",
                            allocator = context.temp_allocator,
                        )
                        property = strings.concatenate(
                            {property, "(", args_str, ")"},
                            allocator = context.temp_allocator,
                        )
                    }
                }

                new_node := new(ExprNode)
                new_node^ = PropertyAccess {
                    object   = left,
                    property = property,
                }
                left = new_node
            } else {
                break
            }
        } else if expect_token(parser, .PIPE) {
            consume_token(parser) // consume '|'
            if expect_token(parser, .IDENTIFIER) {
                filter_name := parser.current_token.value
                consume_token(parser)

                new_node := new(ExprNode)
                new_node^ = FilterExpression {
                    expr        = left,
                    filter_name = filter_name,
                }
                left = new_node
            } else {
                break
            }
        } else {
            break
        }
    }

    return left
}

parse_comparison :: proc(parser: ^ExprParser) -> ^ExprNode {
    left := parse_postfix(parser)
    if left == nil {
        return nil
    }

    for {
        if expect_token(parser, .EQUALS) {
            op := parser.current_token.value
            consume_token(parser)
            right := parse_postfix(parser)
            if right == nil {
                return left
            }

            new_node := new(ExprNode)
            new_node^ = BinaryOp {
                left     = left,
                operator = op,
                right    = right,
            }
            left = new_node
        } else if expect_token(parser, .NOT_EQUALS) {
            op := parser.current_token.value
            consume_token(parser)
            right := parse_postfix(parser)
            if right == nil {
                return left
            }

            new_node := new(ExprNode)
            new_node^ = BinaryOp {
                left     = left,
                operator = op,
                right    = right,
            }
            left = new_node
        } else if expect_token(parser, .IS) {
            consume_token(parser) // consume 'is'
            if expect_token(parser, .DEFINED) {
                consume_token(parser) // consume 'defined'

                new_node := new(ExprNode)
                new_node^ = BinaryOp {
                    left     = left,
                    operator = "is defined",
                    right    = nil,
                }
                left = new_node
            } else {
                break
            }
        } else {
            break
        }
    }

    return left
}

parse_logical :: proc(parser: ^ExprParser) -> ^ExprNode {
    left := parse_comparison(parser)
    if left == nil {
        return nil
    }

    for expect_token(parser, .AND) {
        op := parser.current_token.value
        consume_token(parser)
        right := parse_comparison(parser)
        if right == nil {
            return left
        }

        new_node := new(ExprNode)
        new_node^ = BinaryOp {
            left     = left,
            operator = op,
            right    = right,
        }
        left = new_node
    }

    return left
}

parse_expression :: proc(input: string) -> ^ExprNode {
    parser := init_expr_parser(input)
    return parse_logical(&parser)
}

// AST evaluation
eval_ast_node :: proc(node: ^ExprNode, ctx: ^json.Object) -> json.Value {
    if node == nil {
        return nil
    }

    switch &n in node^ {
    case Variable:
        return ctx[n.name]

    case PropertyAccess:
        obj_value := eval_ast_node(n.object, ctx)
        if obj_value == nil {
            return nil
        }

        #partial switch &v in obj_value {
        case json.Object:
            // Handle special methods like isoformat() and strftime()
            if strings.ends_with(n.property, "()") {
                method_name := n.property[:len(n.property) - 2]
                if method_name == "isoformat" {
                    return obj_value // Return the original string for isoformat
                }
            } else if strings.starts_with(n.property, `strftime("`) &&
               strings.ends_with(n.property, `")`) {
                // Extract format string from strftime("format")
                format_str := n.property[len(`strftime("`):]
                format_str = format_str[:len(format_str) - 2] // Remove ") 

                // Look for the actual date value in the object
                if date_val, has_date := v["__value__"]; has_date {
                    if date_str, ok := date_val.(json.String); ok {
                        ts, _, _ := time.iso8601_to_time_and_offset(string(date_str))
                        if format_str == "%Y, %B %d" {
                            return json.String(
                                fmt.aprintf(
                                    "%d, %s %02d",
                                    time.year(ts),
                                    time.month(ts),
                                    time.day(ts),
                                    allocator = context.temp_allocator,
                                ),
                            )
                        }
                    }
                }
                return nil
            }
            return v[n.property]

        case json.String:
            // Handle date formatting for strings
            if n.property == "isoformat()" {
                return obj_value
            } else if n.property == `strftime("%Y, %B %d")` {
                ts, _, _ := time.iso8601_to_time_and_offset(string(v))
                return json.String(
                    fmt.aprintf(
                        "%d, %s %02d",
                        time.year(ts),
                        time.month(ts),
                        time.day(ts),
                        allocator = context.temp_allocator,
                    ),
                )
            }
            return nil
        }
        return nil

    case FunctionCall:
        // Handle special functions like lang_display_name
        if n.name == "lang_display_name" && len(n.args) > 0 {
            arg_value := eval_ast_node(&n.args[0], ctx)
            if lang_str, ok := arg_value.(json.String); ok {
                switch string(lang_str) {
                case "en":
                    return json.String("English")
                case "pt-br":
                    return json.String("Português (Brasil)")
                case:
                    return lang_str
                }
            }
        }
        return nil

    case FilterExpression:
        expr_value := eval_ast_node(n.expr, ctx)
        switch n.filter_name {
        case "striptags":
            // For now, just return the original value (no HTML stripping needed)
            return expr_value
        }
        return expr_value

    case BinaryOp:
        if n.operator == "is defined" {
            // For "is defined", check if the left side variable exists in context
            if var_node, ok := n.left^.(Variable); ok {
                return json.Boolean(var_node.name in ctx)
            }
            return json.Boolean(false)
        }

        left_val := eval_ast_node(n.left, ctx)
        right_val := eval_ast_node(n.right, ctx)

        switch n.operator {
        case "==":
            return json.Boolean(eql_values(left_val, right_val))
        case "!=":
            return json.Boolean(!eql_values(left_val, right_val))
        case "and":
            return json.Boolean(is_truthy(left_val) && is_truthy(right_val))
        }
        return json.Boolean(false)

    case Literal:
        return n.value
    }

    return nil
}

is_truthy :: proc(value: json.Value) -> bool {
    if value == nil {
        return false
    }
    switch v in value {
    case json.Null:
        return false
    case json.Boolean:
        return v
    case json.String:
        return len(v) > 0
    case json.Integer:
        return v != 0
    case json.Float:
        return v != 0
    case json.Object:
        return true
    case json.Array:
        return len(v) > 0
    }
    return false
}

init_tokenizer :: proc(input: string) -> Tokenizer {
    return Tokenizer{input = input, pos = 0, line = 1, column = 1}
}

peek_char :: proc(tokenizer: ^Tokenizer, offset: int = 0) -> u8 {
    pos := tokenizer.pos + offset
    if pos >= len(tokenizer.input) {
        return 0
    }
    return tokenizer.input[pos]
}

advance_char :: proc(tokenizer: ^Tokenizer) -> u8 {
    if tokenizer.pos >= len(tokenizer.input) {
        return 0
    }

    char := tokenizer.input[tokenizer.pos]
    tokenizer.pos += 1

    if char == '\n' {
        tokenizer.line += 1
        tokenizer.column = 1
    } else {
        tokenizer.column += 1
    }

    return char
}

advance_until :: proc(
    tokenizer: ^Tokenizer,
    pattern: string,
) -> (
    found: bool,
    content: string,
) {
    start_pos := tokenizer.pos

    for tokenizer.pos < len(tokenizer.input) {
        if tokenizer.pos + len(pattern) <= len(tokenizer.input) {
            if tokenizer.input[tokenizer.pos:tokenizer.pos + len(pattern)] == pattern {
                content = tokenizer.input[start_pos:tokenizer.pos]
                // Advance past the pattern
                for _ in 0 ..< len(pattern) {
                    advance_char(tokenizer)
                }
                return true, content
            }
        }
        advance_char(tokenizer)
    }

    // If not found, return content from start to end
    content = tokenizer.input[start_pos:tokenizer.pos]
    return false, content
}

next_token :: proc(tokenizer: ^Tokenizer) -> Token {
    if tokenizer.pos >= len(tokenizer.input) {
        return Token {
            type = .EOF,
            value = "",
            line = tokenizer.line,
            column = tokenizer.column,
            start_pos = tokenizer.pos,
            end_pos = tokenizer.pos,
        }
    }

    start_line := tokenizer.line
    start_column := tokenizer.column
    start_pos := tokenizer.pos

    // Check for expressions {{ }}
    if peek_char(tokenizer) == '{' && peek_char(tokenizer, 1) == '{' {
        advance_char(tokenizer) // {
        advance_char(tokenizer) // {

        found, content := advance_until(tokenizer, "}}")
        if !found {
            // Malformed expression, treat remaining content as text starting from the first {
            tokenizer.pos = start_pos
            tokenizer.line = start_line
            tokenizer.column = start_column
            // Fall through to regular text processing
        } else {
            return Token {
                type = .EXPRESSION,
                value = strings.trim_space(content),
                line = start_line,
                column = start_column,
                start_pos = start_pos,
                end_pos = tokenizer.pos,
            }
        }
    }

    // Check for statements {% %}
    if peek_char(tokenizer) == '{' && peek_char(tokenizer, 1) == '%' {
        advance_char(tokenizer) // {
        advance_char(tokenizer) // %

        found, content := advance_until(tokenizer, "%}")
        if !found {
            // Malformed statement, treat remaining content as text starting from the first {
            tokenizer.pos = start_pos
            tokenizer.line = start_line
            tokenizer.column = start_column
            // Fall through to regular text processing
        } else {
            return Token {
                type = .STATEMENT,
                value = strings.trim_space(content),
                line = start_line,
                column = start_column,
                start_pos = start_pos,
                end_pos = tokenizer.pos,
            }
        }
    }

    // Regular text - read until next { or end of input
    text_content: strings.Builder
    defer strings.builder_destroy(&text_content)

    for tokenizer.pos < len(tokenizer.input) {
        char := peek_char(tokenizer)
        if char == '{' {
            // Only break if we haven't started processing text yet
            // If we're already in text mode (start_pos == tokenizer.pos), 
            // we should consume the { as part of the text
            if tokenizer.pos > start_pos {
                break
            }
        }
        strings.write_byte(&text_content, advance_char(tokenizer))
    }

    value := strings.clone_from(
        strings.to_string(text_content),
        allocator = context.temp_allocator,
    )

    return Token {
        type = .TEXT,
        value = value,
        line = start_line,
        column = start_column,
        start_pos = start_pos,
        end_pos = tokenizer.pos,
    }
}

// New token-based template renderer
render_template_string_v2 :: proc(templ_str: string, ctx: ^json.Object) -> string {
    tokenizer := init_tokenizer(templ_str)

    builder: strings.Builder
    defer strings.builder_destroy(&builder)

    if_cond_stack: [dynamic]bool
    defer delete(if_cond_stack)

    is_copying :: proc(if_cond_stack: ^[dynamic]bool) -> bool {
        if len(if_cond_stack) == 0 {
            return true
        }
        return if_cond_stack[len(if_cond_stack) - 1]
    }

    for {
        token := next_token(&tokenizer)

        if token.type == .EOF {
            break
        }

        #partial switch token.type {

        case .TEXT:
            if is_copying(&if_cond_stack) {
                strings.write_string(&builder, token.value)
            }

        case .EXPRESSION:
            if is_copying(&if_cond_stack) {
                result := eval_expr(token.value, ctx)
                strings.write_string(&builder, to_string(result))
            }

        case .STATEMENT:
            stmt_parts := strings.split(token.value, " ")
            defer delete(stmt_parts)

            if len(stmt_parts) == 0 {
                continue
            }

            switch stmt_parts[0] {
            case "if":
                cond_val := eval_condition(stmt_parts[1:], ctx)
                append(&if_cond_stack, cond_val)

            case "else":
                if len(if_cond_stack) > 0 {
                    if_cond_stack[len(if_cond_stack) - 1] =
                    !if_cond_stack[len(if_cond_stack) - 1]
                }

            case "endif":
                if len(if_cond_stack) > 0 {
                    pop(&if_cond_stack)
                }

            case "for":
                if len(stmt_parts) >= 4 &&
                   stmt_parts[2] == "in" &&
                   is_copying(&if_cond_stack) {
                    loop_var := stmt_parts[1]
                    loop_iterable := eval_expr(stmt_parts[3], ctx)

                    // Parse for-loop content until endfor
                    loop_tokens: [dynamic]Token
                    defer delete(loop_tokens)

                    for_depth := 1
                    for for_depth > 0 {
                        inner_token := next_token(&tokenizer)
                        if inner_token.type == .EOF {
                            break
                        }
                        if inner_token.type == .STATEMENT {
                            inner_parts := strings.split(inner_token.value, " ")
                            defer delete(inner_parts)
                            if len(inner_parts) > 0 {
                                if inner_parts[0] == "for" {
                                    for_depth += 1
                                } else if inner_parts[0] == "endfor" {
                                    for_depth -= 1
                                }
                            }
                        }
                        if for_depth > 0 {
                            append(&loop_tokens, inner_token)
                        }
                    }

                    // Render for-loop content
                    #partial switch v in loop_iterable {
                    case json.Array:
                        for item in v {
                            loop_iter_ctx := clone_context(ctx)
                            loop_iter_ctx[loop_var] = item

                            inner_result := render_tokens_v2(
                                loop_tokens[:],
                                &loop_iter_ctx,
                            )
                            strings.write_string(&builder, inner_result)
                        }
                    case nil, json.Null:
                    // ignore
                    case:
                        log.error("Looping over non-list value not yet supported")
                    }
                }

            case "endfor":
            // Handled in for-loop processing

            case:
            // Unknown statement, ignore
            }
        }
    }

    return strings.clone_from(
        strings.to_string(builder),
        allocator = context.temp_allocator,
    )
}

render_tokens_v2 :: proc(tokens: []Token, ctx: ^json.Object) -> string {
    builder: strings.Builder
    defer strings.builder_destroy(&builder)

    if_cond_stack: [dynamic]bool
    defer delete(if_cond_stack)

    is_copying :: proc(if_cond_stack: ^[dynamic]bool) -> bool {
        if len(if_cond_stack) == 0 {
            return true
        }
        return if_cond_stack[len(if_cond_stack) - 1]
    }

    for i := 0; i < len(tokens); i += 1 {
        token := tokens[i]
        switch token.type {
        case .TEXT:
            if is_copying(&if_cond_stack) {
                strings.write_string(&builder, token.value)
            }

        case .EXPRESSION:
            if is_copying(&if_cond_stack) {
                result := eval_expr(token.value, ctx)
                strings.write_string(&builder, to_string(result))
            }

        case .STATEMENT:
            stmt_parts := strings.split(token.value, " ")
            defer delete(stmt_parts)

            if len(stmt_parts) == 0 {
                continue
            }

            switch stmt_parts[0] {
            case "if":
                cond_val := eval_condition(stmt_parts[1:], ctx)
                append(&if_cond_stack, cond_val)

            case "else":
                if len(if_cond_stack) > 0 {
                    if_cond_stack[len(if_cond_stack) - 1] =
                    !if_cond_stack[len(if_cond_stack) - 1]
                }

            case "endif":
                if len(if_cond_stack) > 0 {
                    pop(&if_cond_stack)
                }

            case "for":
                if len(stmt_parts) >= 4 &&
                   stmt_parts[2] == "in" &&
                   is_copying(&if_cond_stack) {
                    loop_var := stmt_parts[1]
                    loop_iterable := eval_expr(stmt_parts[3], ctx)

                    // Find current position in token stream
                    current_index := find_current_token_index(tokens, token)

                    if current_index >= 0 {
                        // Collect loop tokens
                        loop_tokens, end_index := collect_for_loop_tokens(
                            tokens,
                            current_index,
                        )
                        defer delete(loop_tokens)

                        // Render for-loop content
                        #partial switch v in loop_iterable {
                        case json.Array:
                            for item in v {
                                loop_iter_ctx := clone_context(ctx)
                                loop_iter_ctx[loop_var] = item

                                inner_result := render_tokens_v2(
                                    loop_tokens[:],
                                    &loop_iter_ctx,
                                )
                                strings.write_string(&builder, inner_result)
                            }
                        case nil, json.Null:
                        // ignore
                        case:
                            log.error("Looping over non-list value not yet supported")
                        }

                        // Skip to after the matching endfor
                        i = end_index
                    }
                }

            case "endfor":
            // Handled in for-loop processing above
            }

        case .EOF:
            break
        }
    }

    return strings.clone_from(
        strings.to_string(builder),
        allocator = context.temp_allocator,
    )
}

// Find the index of a specific token in the tokens array
@(private = "file")
find_current_token_index :: proc(tokens: []Token, target_token: Token) -> int {
    for tok, i in tokens {
        if tok.type == .STATEMENT &&
           strings.compare(tok.value, target_token.value) == 0 {
            return i
        }
    }
    return -1
}

// Extract tokens between matching for/endfor statements
@(private = "file")
collect_for_loop_tokens :: proc(
    tokens: []Token,
    start_index: int,
) -> (
    loop_tokens: [dynamic]Token,
    end_index: int,
) {
    if start_index < 0 || start_index >= len(tokens) {
        return {}, -1
    }

    loop_tokens = make([dynamic]Token)
    for_depth := 1

    for i in start_index + 1 ..< len(tokens) {
        tok := tokens[i]
        if tok.type == .STATEMENT {
            parts := strings.split(tok.value, " ")
            defer delete(parts)
            if len(parts) > 0 {
                if parts[0] == "for" {
                    for_depth += 1
                } else if parts[0] == "endfor" {
                    for_depth -= 1
                }
            }
        }
        if for_depth > 0 {
            append(&loop_tokens, tok)
        } else {
            end_index = i
            break
        }
    }

    return loop_tokens, end_index
}

// Find the index of the matching endfor statement
@(private = "file")
find_matching_endfor :: proc(tokens: []Token, start_index: int) -> int {
    if start_index < 0 || start_index >= len(tokens) {
        return -1
    }

    skip_depth := 1
    for j in start_index + 1 ..< len(tokens) {
        tok := tokens[j]
        if tok.type == .STATEMENT {
            parts := strings.split(tok.value, " ")
            defer delete(parts)
            if len(parts) > 0 {
                if parts[0] == "for" {
                    skip_depth += 1
                } else if parts[0] == "endfor" {
                    skip_depth -= 1
                    if skip_depth == 0 {
                        return j
                    }
                }
            }
        }
    }
    return -1
}

// helpers to get the top of the stack
@(private = "file")
top_slice :: proc(li: []$T) -> Maybe(T) {
    if len(li) == 0 {
        return nil
    }
    return li[len(li) - 1]
}

@(private = "file")
top_dyn_arr :: proc(li: [dynamic]$T) -> Maybe(T) {
    return top_slice(li[:])
}

@(private = "file")
top :: proc {
    top_slice,
    top_dyn_arr,
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
    case json.Float:
        // Check if this is actually an integer that was parsed as float
        if v == f64(i64(v)) {
            return fmt.aprintf("%d", i64(v), allocator = context.temp_allocator)
        }
        return fmt.aprintf("%f", v, allocator = context.temp_allocator)
    case json.Integer:
        return fmt.aprintf("%d", v, allocator = context.temp_allocator)
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

clone_context :: proc(ctx: ^json.Object) -> json.Object {
    cloned_obj := json.clone_value(ctx^, allocator = context.temp_allocator)
    cloned_ctx := cloned_obj.(json.Object)
    return cloned_ctx
}

unquote :: proc(s: string) -> string {
    return strings.trim(s, `"`)
}


// New AST-based expression evaluation - replaces hardcoded eval_expr
eval_expr :: proc(expr: string, ctx: ^json.Object) -> json.Value {
    ast := parse_expression(expr)
    return eval_ast_node(ast, ctx)
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
    log.error("Condition not yet supported:", token_list)
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
            return strings.trim_space(expr_read), true
        }
        // if we couldn't find the end of the expression, let's put back the "{%"
        // we read at first
        strings.reader_unread_rune(reader) // %
        strings.reader_unread_rune(reader) // {
        return "", false
    }
    return "", false
}


parse_template_blocks :: proc(
    reader: ^strings.Reader,
    templ_blocks: ^map[string]string,
) -> bool {
    block_name_stack: [dynamic]string
    block_index_stack: [dynamic]i64
    defer delete(block_name_stack)
    defer delete(block_index_stack)

    read_ok: bool
    next_stmt: string
    next_stmt, read_ok = read_until_next_stmt(reader)
    for read_ok {
        next_stmt_split := strings.split(next_stmt, " ")
        defer delete(next_stmt_split)

        if next_stmt_split[0] == "block" {
            if len(next_stmt_split) != 2 {
                log.error("Template syntax error: missing block name")
                return false
            }
            block_name := unquote(next_stmt_split[1])
            append(&block_name_stack, block_name)
            append(&block_index_stack, reader.i)
        } else if next_stmt_split[0] == "endblock" {
            if len(block_name_stack) == 0 {
                log.error("Template syntax error: endblock without matching block")
                return false
            }
            expected_block_name := block_name_stack[len(block_name_stack) - 1]
            if len(next_stmt_split) > 1 {
                endblock_name := unquote(next_stmt_split[1])
                if endblock_name != expected_block_name {
                    log.error("Template syntax error: endblock name mismatch")
                    return false
                }
            }
            block_name := pop(&block_name_stack)
            start_index := pop(&block_index_stack)
            block_content := reader.s[start_index:(reader.i)]
            block_content = block_content[:strings.last_index(block_content, "{%")] // remove the endblock tag
            templ_blocks[block_name] = block_content
        }
        next_stmt, read_ok = read_until_next_stmt(reader)
    }

    if len(block_name_stack) != 0 || len(block_index_stack) != 0 {
        log.error(
            "Template syntax error: missing endblock somewhere -- block stack was:",
            block_name_stack,
        )
        return false
    }

    return true
}

@(private = "file")
resolve_template_blocks :: proc(
    env: ^Environment,
    templ_str: string,
    child_blocks: map[string]string,
) -> (
    string,
    bool,
) {
    builder: strings.Builder
    defer strings.builder_destroy(&builder)

    reader: strings.Reader
    strings.reader_init(&reader, templ_str)

    block_name_stack: [dynamic]string
    defer delete(block_name_stack)

    // log.info("child_blocks", child_blocks)

    copying_or_skipping :: proc(
        block_name_stack: [dynamic]string,
        child_blocks: map[string]string,
    ) -> ParsingStatementsState {
        top_block_stack := top(block_name_stack)
        if top_block_stack == nil {     // if we're not inside a block
            return .Copying
        }
        if top_block_stack.? not_in child_blocks {     // if the current block is not overriden
            return .Copying
        }
        return .Skipping
    }

    state: ParsingStatementsState = .Copying
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
                state = copying_or_skipping(block_name_stack, child_blocks)

                if state == .Copying {
                    strings.write_rune(&builder, '{')
                    strings.write_rune(&builder, char)
                }
            }
        case .Statement:
            // unread current rune, let read_until + trim do all the work ;)
            strings.reader_unread_rune(&reader)

            before_index := reader.i
            stmt_read, stmt_read_ok := read_until(&reader, "%}")
            if !stmt_read_ok {
                state = copying_or_skipping(block_name_stack, child_blocks)
                continue
            }
            stmt_split := strings.split(strings.trim_space(stmt_read), " ")
            defer delete(stmt_split)

            unhandled_statement := true
            if stmt_split[0] == "block" {
                unhandled_statement = false
                if len(stmt_split) != 2 {
                    log.error("Template syntax error: missing block name")
                    return "", false
                }
                block_name := unquote(stmt_split[1])
                append(&block_name_stack, block_name)
                if block_name in child_blocks {
                    state = .Skipping
                } else {
                    state = .Copying
                }
            } else if stmt_split[0] == "endblock" {
                unhandled_statement = false
                block_name := pop(&block_name_stack)
                if block_name in child_blocks {
                    block_content, ok := resolve_template_blocks(
                        env,
                        child_blocks[block_name],
                        child_blocks,
                    )
                    if ok {
                        strings.write_string(&builder, block_content)
                    } else {
                        return "", false
                    }
                }
            }

            state = copying_or_skipping(block_name_stack, child_blocks)

            if state == .Copying && unhandled_statement {
                sli := reader.s[before_index:reader.i]
                strings.write_string(&builder, "{%")
                strings.write_string(&builder, stmt_read)
                strings.write_string(&builder, "%}")
            }
        }
    }
    return strings.clone_from(
            strings.to_string(builder),
            allocator = context.temp_allocator,
        ),
        true
}

resolve_extends_template :: proc(
    env: ^Environment,
    template_name: string,
) -> (
    result: string,
    ok: bool,
) {
    if template_name not_in env.loaded_templates {
        resolve_template_includes(env, template_name) or_return
    }
    loaded_templ_str := env.loaded_templates[template_name]
    if !strings.starts_with(loaded_templ_str, "{% extends") {
        return loaded_templ_str, true
    }
    builder: strings.Builder
    defer strings.builder_destroy(&builder)

    reader: strings.Reader
    strings.reader_init(&reader, loaded_templ_str)

    // read parent template name from extends statement
    strings.reader_seek(&reader, 2, .Current)
    parent_template_name: string
    if stmt_read, ok := read_until(&reader, "%}"); ok {
        stmt_read := strings.trim_space(stmt_read)
        stmt_split := strings.split(stmt_read, " ")
        defer delete(stmt_split)

        if stmt_split[0] != "extends" || len(stmt_split) != 2 {
            log.error("stmt_split:", stmt_split)
            return "ERROR: WRONG EXTEND TEMPLATE SYNTAX", false
        }
        parent_template_name = unquote(stmt_split[1])
        if parent_template_name not_in env.raw_templates {
            load_template(env, parent_template_name) or_return
        }
        if parent_template_name not_in env.loaded_templates {
            resolve_template_includes(env, parent_template_name) or_return
        }
    }

    template_blocks: map[string]string
    defer delete(template_blocks)

    parse_template_blocks(&reader, &template_blocks) or_return

    result = resolve_template_blocks(
        env,
        env.loaded_templates[parent_template_name],
        template_blocks,
    ) or_return
    return result, true
}


resolve_template_includes :: proc(env: ^Environment, template_name: string) -> bool {
    if template_name not_in env.raw_templates {
        // template not found
        return false
    }

    builder: strings.Builder
    defer strings.builder_destroy(&builder)

    state: ParsingStatementsState
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

            if stmt_read, ok := read_until(&reader, "%}"); ok {
                stmt_read := strings.trim_space(stmt_read)
                stmt_split := strings.split(stmt_read, " ")
                defer delete(stmt_split)

                if stmt_split[0] == "include" {
                    if len(stmt_split) != 2 {
                        // "ERROR INCLUDING TEMPLATE -- too many params"
                        return false
                    }
                    to_include := unquote(stmt_split[1])
                    if to_include not_in env.raw_templates {
                        load_template(env, to_include)
                    }
                    resolve_template_includes(env, to_include) or_return
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

load_template :: proc(env: ^Environment, template_name: string) -> bool {
    if template_name in env.loaded_templates {
        return true
    }
    template_path := strings.join({TEMPLATE_DIR, template_name}, "")
    defer delete(template_path)
    template_data := os.read_entire_file(template_path) or_return
    env.raw_templates[template_name] = string(template_data)
    resolve_template_includes(env, template_name) or_return
    return true
}


render_template :: proc(
    env: ^Environment,
    template_name: string,
    ctx: ^json.Object,
) -> (
    result: string,
    ok: bool,
) {
    load_template(env, template_name) or_return
    template_str := resolve_extends_template(env, template_name) or_return
    // log.debug("final template is\n", template_str)
    // result = render_template_string(template_str, ctx)
    result = render_template_string_v2(template_str, ctx)
    // TODO: improve render_template_string error handling
    return result, true
}
