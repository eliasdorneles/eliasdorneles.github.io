package sitegen

import "core:encoding/json"
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
    parsed, _ := json.parse_string(`{"article": {"date":  "2025-06-03T00:01:00+02:00"}}`)
    defer json.destroy_value(parsed)

    ctx := parsed.(json.Object)

    v: Value = ctx
    expect_str(
        t,
        "2025-06-03T00:01:00+02:00",
        to_string(eval_expr("article.date.isoformat()", &ctx)),
    )
    expect_str(
        t,
        "2025, June 03",
        to_string(eval_expr("article.date.strftime(\"%Y, %B %d\")", &ctx)),
    )
}

@(test)
test_eval_expr :: proc(t: ^testing.T) {
    ctx1 := make(json.Object)
    defer delete(ctx1)
    ctx2 := make(json.Object)
    defer delete(ctx2)
    ctx3 := make(json.Object)
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
    ctx1 := make(json.Object)
    defer delete(ctx1)
    ctx2 := make(json.Object)
    defer delete(ctx2)
    ctx3 := make(json.Object)
    defer delete(ctx3)

    ctx3["city"] = "Paris"
    ctx2["country"] = ctx3
    ctx1["world"] = ctx2

    list: json.Array
    append(&list, "um")
    append(&list, "dois")
    append(&list, "tres")
    ctx1["list"] = list

    result: string
    result = render_template("hello {{   city   }} bye", &ctx3)
    expect_str(t, "hello Paris bye", result)

    result = render_template("hello {{ world.country.city }} bye", &ctx1)
    expect_str(t, "hello Paris bye", result)

    result = render_template("hello {{ world }} bye", &ctx1)
    expect_str(t, `hello {"country":{"city":"Paris"}} bye`, result)

    result = render_template("hello {{ list }} bye", &ctx1)
    expect_str(t, `hello ["um","dois","tres"] bye`, result)

    result = render_template("hello [{{ not.valid }}] bye", &ctx1)
    expect_str(t, "hello [] bye", result)

    result = render_template("hello {{ world.country.city.invalid }} bye", &ctx1)
    expect_str(t, "hello  bye", result)
}

@(test)
test_render_template_translation_lang_display :: proc(t: ^testing.T) {
    translation := make(json.Object)
    translation["lang"] = "en"
    defer delete(translation)
    ctx := make(json.Object)
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
    article := make(json.Object)
    defer delete(article)
    article["title"] = "One giga monkeys"

    ctx := make(json.Object)
    defer delete(ctx)
    ctx["article"] = article

    templ_str: string

    // when:
    templ_str = "{% if article %}{{ article.title }}{% endif %}"
    // then:
    expect_str(t, "One giga monkeys", render_template(templ_str, &ctx))

    // when:
    templ_str =
    "{% if nothing %}nothing{% endif %}Article: {% if article %}{{ article.title }}{% endif %}"
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

@(test)
test_render_template_for :: proc(t: ^testing.T) {
    // given:
    parsed, _ := json.parse_string(
        `
        {
            "items": [
                {"name": "Apple",   "row": ["a", "b", "c"]},
                {"name": "Banana",  "row": ["d", "e", "f"]},
                {"name": "Kiwi",    "row": ["g", "h", "i"]}
            ]
        }
        `,
    )
    defer json.destroy_value(parsed)

    ctx := parsed.(json.Object)

    templ_str: string

    // when:
    templ_str = "{% for it in items %}- {{ it.name }}{% endfor %}"
    // then:
    expect_str(t, "- Apple- Banana- Kiwi", render_template(templ_str, &ctx))

    // and when:
    templ_str =
    "BEGIN {% for it in items %}: {% for x in it.row %}{{ x }}_{% endfor %}{% endfor %} END"
    // then:
    expect_str(t, "BEGIN : a_b_c_: d_e_f_: g_h_i_ END", render_template(templ_str, &ctx))

    // and when:
    templ_str = strings.trim_space(
        `
<ul>
{% for it in items %}
    <li>{{ it.name }}</li>
{% endfor %}
</ul>
    `,
    )
    expected := strings.trim_space(
        `
<ul>

    <li>Apple</li>

    <li>Banana</li>

    <li>Kiwi</li>

</ul>
    `,
    )
    // then:
    expect_str(t, expected, render_template(templ_str, &ctx))
}
