package sitegen

import "core:log"
import "core:strings"
import "core:testing"

@(test)
test_eval_context_path :: proc(t: ^testing.T) {
    ctx1 := make(Context)
    defer delete(ctx1)
    ctx2 := make(Context)
    defer delete(ctx2)
    ctx3 := make(Context)
    defer delete(ctx3)

    // NOTE: the order matters here, because the struct assignments are copying!
    ctx3["city"] = "Paris"
    ctx2["country"] = ctx3
    ctx1["world"] = ctx2

    ctx1["um"] = "1"

    v: Value = ctx1
    testing.expect_value(t, eval_context_path(&v, {"um"}).(string), "1")
    testing.expect_value(
        t,
        eval_context_path(&v, {"world", "country", "city"}).(string),
        "Paris",
    )
    testing.expect(t, eval_context_path(&v, {"nothing"}) == nil)
    testing.expect(t, eval_context_path(&v, {"world", "nothing"}) == nil)
}

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

    result := render_template("simple content", &ctx)
    expect_str(t, "simple content", result)

    ctx["first_name"] = "Sheldon"
    ctx["last_name"] = "Cooper"

    result = render_template("hello {{ first_name }} bye {{ last_name   }} tchuss", &ctx)
    expect_str(t, "hello Sheldon bye Cooper tchuss", result)
}

@(test)
test_context_dot_access :: proc(t: ^testing.T) {
    ctx1 := make(Context)
    defer delete(ctx1)
    ctx2 := make(Context)
    defer delete(ctx2)
    ctx3 := make(Context)
    defer delete(ctx3)

    ctx3["city"] = "Paris"
    ctx2["country"] = ctx3
    ctx1["world"] = ctx2


    result: string
    result = render_template("hello {{ world.country.city }} bye", &ctx1)
    expect_str(t, "hello Paris bye", result)

    result = render_template("hello {{ world }} bye", &ctx1)
    expect_str(t, "hello (object) bye", result)

    result = render_template("hello [{{ not.valid }}] bye", &ctx1)
    expect_str(t, "hello [] bye", result)

    result = render_template("hello {{ world.country.city.invalid }} bye", &ctx1)
    expect_str(t, "hello  bye", result)
}
