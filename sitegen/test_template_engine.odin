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
test_eval_expr_isoformat :: proc(t: ^testing.T) {
    ctx := make(Context)
    defer delete(ctx)
    article := make(Context)
    defer delete(article)

    date_isoformat := "2025-06-03T00:01:00+02:00"
    article["date"] = date_isoformat
    ctx["article"] = article

    v: Value = ctx
    expect_str(t, date_isoformat, to_string(eval_expr("article.date.isoformat()", &ctx)))
    expect_str(
        t,
        "2025, June 03",
        to_string(eval_expr("article.date.strftime(\"%Y, %B %d\")", &ctx)),
    )
}

@(test)
test_eval_expr :: proc(t: ^testing.T) {
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

    expect_str(t, "1", to_string(eval_expr("um", &ctx1)))
    expect_str(t, "Paris", to_string(eval_expr("world.country.city", &ctx1)))
    expect_str(t, "", to_string(eval_expr("nothing", &ctx1)))
    expect_str(t, "", to_string(eval_expr("world.nothing", &ctx1)))

    // check striptags doesn't break
    expect_str(t, "Paris", to_string(eval_expr("world.country.city|striptags", &ctx1)))
}

@(test)
test_render_template_simple_expr :: proc(t: ^testing.T) {
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
    result = render_template("hello {{   city   }} bye", &ctx3)
    expect_str(t, "hello Paris bye", result)

    result = render_template("hello {{ world.country.city }} bye", &ctx1)
    expect_str(t, "hello Paris bye", result)

    result = render_template("hello {{ world }} bye", &ctx1)
    expect_str(t, "hello (object) bye", result)

    result = render_template("hello [{{ not.valid }}] bye", &ctx1)
    expect_str(t, "hello [] bye", result)

    result = render_template("hello {{ world.country.city.invalid }} bye", &ctx1)
    expect_str(t, "hello  bye", result)
}

@(test)
test_render_template_translation_lang_display :: proc(t: ^testing.T) {
    translation := make(Context)
    translation["lang"] = "en"
    defer delete(translation)
    ctx := make(Context)
    defer delete(ctx)
    ctx["translation"] = translation

    result: string
    result = render_template("Lang: {{ lang_display_name(translation.lang) }}", &ctx)
    expect_str(t, "Lang: English", result)

    translation["lang"] = "pt-br"
    result = render_template("Lang: {{ lang_display_name(translation.lang) }}", &ctx)
    expect_str(t, "Lang: Português (Brasil)", result)
}

@(test)
test_render_template_if :: proc(t: ^testing.T) {
    // given:
    article := make(Context)
    defer delete(article)
    article["title"] = "One giga monkeys"

    ctx := make(Context)
    defer delete(ctx)
    ctx["article"] = article

    templ_str: string

    // when:
    templ_str = "{% if article %}{{ article.title }}{% endif %}"
    // then:
    expect_str(t, "One giga monkeys", render_template(templ_str, &ctx))

    // when:
    templ_str = "{% if nothing %}nothing{% endif %}Article: {% if article %}{{ article.title }}{% endif %}"
    // then:
    expect_str(t, "Article: One giga monkeys", render_template(templ_str, &ctx))

    // when:
    templ_str = "{% if nothing %}nothing{% else %}something{% endif %}"
    // then:
    expect_str(t, "something", render_template(templ_str, &ctx))

    // when:
    templ_str = "{% if nothing %}nothing{% else %}something{% endif %}"
    // then:
    expect_str(t, "something", render_template(templ_str, &ctx))

    // when:
    templ_str = "{% if article %}{{ article.title }}{% else %}no article{% endif %}"
    // then:
    expect_str(t, "One giga monkeys", render_template(templ_str, &ctx))
}

