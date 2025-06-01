package sitegen

import "core:log"
import "core:strings"
import "core:testing"

expect_str :: proc(t: ^testing.T, expected: string, result: string) {
    testing.expectf(
        t,
        strings.compare(result, expected) == 0,
        "Expected: [%s] but got [%s]",
        expected,
        result,
    )
}

@(test)
test_simple_expr_eval :: proc(t: ^testing.T) {
    ctx := make(Context)
    defer delete(ctx)

    result := render_template("simple content", ctx)
    expect_str(t, "simple content", result)

    ctx["first_name"] = "Sheldon"
    ctx["last_name"] = "Cooper"

    result = render_template("hello {{ first_name }} bye {{ last_name   }} tchuss", ctx)
    expect_str(t, "hello Sheldon bye Cooper tchuss", result)
}
