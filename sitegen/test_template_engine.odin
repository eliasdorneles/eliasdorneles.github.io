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

    list: []Value = {"um", "dois", "tres"}
    ctx1["list"] = list

    result: string
    result = render_template("hello {{   city   }} bye", &ctx3)
    expect_str(t, "hello Paris bye", result)

    result = render_template("hello {{ world.country.city }} bye", &ctx1)
    expect_str(t, "hello Paris bye", result)

    result = render_template("hello {{ world }} bye", &ctx1)
    expect_str(t, "hello (OBJECT) bye", result)

    result = render_template("hello {{ list }} bye", &ctx1)
    expect_str(t, "hello (LIST) bye", result)

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
    obj1, obj2, obj3 := make(Context), make(Context), make(Context)
    defer delete(obj1)
    defer delete(obj2)
    defer delete(obj3)
    obj1["name"] = "Apple"
    obj2["name"] = "Banana"
    obj3["name"] = "Kiwi"
    list: []Value = {obj1, obj2, obj3}

    ctx := make(Context)
    defer delete(ctx)
    ctx["items"] = list

    templ_str: string

    // when:
    templ_str = "{% for it in items %}- {{ it.name }}{% endfor %}"
    // then:
    expect_str(t, "- Apple- Banana- Kiwi", render_template(templ_str, &ctx))

    // and given:
    row1: []Value = {"a", "b", "c"}
    row2: []Value = {"d", "e", "f"}
    row3: []Value = {"g", "h", "i"}
    obj1["row"] = row1
    obj2["row"] = row2
    obj3["row"] = row3

    // when:
    templ_str = "BEGIN {% for it in items %}: {% for x in it.row %}{{ x }}_{% endfor %}{% endfor %} END"
    // then:
    expect_str(t, "BEGIN : a_b_c_: d_e_f_: g_h_i_ END", render_template(templ_str, &ctx))

    // when:
    templ_str = strings.trim_space(`
<ul>
{% for it in items %}
    <li>{{ it.name }}</li>
{% endfor %}
</ul>
    `)
    expected := strings.trim_space(`
<ul>

    <li>Apple</li>

    <li>Banana</li>

    <li>Kiwi</li>

</ul>
    `)
    // then:
    expect_str(t, expected, render_template(templ_str, &ctx))
}
