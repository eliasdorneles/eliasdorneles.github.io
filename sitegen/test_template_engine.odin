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
    parsed, _ := json.parse_string(
        `{"world": {"country": {"city": "Paris"}}, "um": "1"}`,
    )
    defer json.destroy_value(parsed)
    ctx := parsed.(json.Object)

    expect_str(t, "1", to_string(eval_expr("um", &ctx)))
    expect_str(t, "Paris", to_string(eval_expr("world.country.city", &ctx)))
    expect_str(t, "", to_string(eval_expr("nothing", &ctx)))
    expect_str(t, "", to_string(eval_expr("world.nothing", &ctx)))

    // check striptags doesn't break
    expect_str(t, "Paris", to_string(eval_expr("world.country.city|striptags", &ctx)))
}

@(test)
test_render_template_simple_expr :: proc(t: ^testing.T) {
    parsed, _ := json.parse_string(
        `{
        "world": {"country": {"city": "Paris"}}, "um": "1",
        "list": ["um", "dois", "tres"]
    }
    `,
    )
    defer json.destroy_value(parsed)
    ctx := parsed.(json.Object)

    country := ctx["world"].(json.Object)["country"].(json.Object)

    result: string
    result = render_template("hello {{   city   }} bye", &country)
    expect_str(t, "hello Paris bye", result)

    result = render_template("hello {{ world.country.city }} bye", &ctx)
    expect_str(t, "hello Paris bye", result)

    result = render_template("hello {{ world }} bye", &ctx)
    expect_str(t, `hello {"country":{"city":"Paris"}} bye`, result)

    result = render_template("hello {{ list }} bye", &ctx)
    expect_str(t, `hello ["um","dois","tres"] bye`, result)

    result = render_template("hello [{{ not.valid }}] bye", &ctx)
    expect_str(t, "hello [] bye", result)

    result = render_template("hello {{ world.country.city.invalid }} bye", &ctx)
    expect_str(t, "hello  bye", result)
}

@(test)
test_render_template_translation_lang_display :: proc(t: ^testing.T) {
    parsed, _ := json.parse_string(`{"translation": {"lang": "en"}, "lang2": "pt-br"}`)
    defer json.destroy_value(parsed)
    ctx := parsed.(json.Object)

    result: string
    result = render_template("Lang: {{ lang_display_name(translation.lang) }}", &ctx)
    expect_str(t, "Lang: English", result)

    result = render_template("Lang: {{ lang_display_name(lang2) }}", &ctx)
    expect_str(t, "Lang: Português (Brasil)", result)
}

@(test)
test_render_template_if :: proc(t: ^testing.T) {
    // given:
    parsed, _ := json.parse_string(
        `{
            "article": {"title":  "One giga monkeys"},
            "nothing": false,
            "fruit": "Banana"
            "banana": {"name": "Banana"}
         }`,
    )
    defer json.destroy_value(parsed)
    ctx := parsed.(json.Object)

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
    templ_str = "{% if nothing is defined %}nothing{% else %}something{% endif %}"
    // then:
    expect_str(t, "nothing", render_template(templ_str, &ctx))

    // when:
    templ_str = "{% if article %}{{ article.title }}{% else %}no article{% endif %}"
    // then:
    expect_str(t, "One giga monkeys", render_template(templ_str, &ctx))

    // when:
    templ_str = `{% if fruit == banana.name %}Bananas for all!{% endif %}`
    // then:
    expect_str(t, "Bananas for all!", render_template(templ_str, &ctx))

    // when:
    templ_str = `{% if fruit != banana.name %}Bananas for all!{% else %}No bananas{% endif %}`
    // then:
    expect_str(t, "No bananas", render_template(templ_str, &ctx))

    // when:
    templ_str = `{% if nothing is defined and fruit == banana.name %}Bananas for all!{% endif %}`
    // then:
    expect_str(t, "Bananas for all!", render_template(templ_str, &ctx))

    // when:
    templ_str = `{% if nothing is defined and fruit == something %}Bananas for all!{% endif %}`
    // then:
    expect_str(t, "", render_template(templ_str, &ctx))
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
