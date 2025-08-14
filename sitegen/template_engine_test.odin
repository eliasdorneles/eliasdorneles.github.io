package sitegen

import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:testing"
import "core:c/libc"

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

    v: json.Value = ctx
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
test_strftime_parse_function :: proc(t: ^testing.T) {
    // Test parsing of strftime calls
    {
        format, ok := parse_strftime_call(`strftime("%Y-%m-%d")`)
        testing.expect(t, ok)
        testing.expect_value(t, format, "%Y-%m-%d")
    }

    {
        format, ok := parse_strftime_call(`strftime('%B %d, %Y')`)
        testing.expect(t, ok)
        testing.expect_value(t, format, "%B %d, %Y")
    }

    // Test invalid calls
    {
        _, ok := parse_strftime_call("not_strftime")
        testing.expect(t, !ok)
    }

    {
        _, ok := parse_strftime_call("strftime(no_quotes)")
        testing.expect(t, !ok)
    }

    {
        _, ok := parse_strftime_call("strftime(\"unclosed")
        testing.expect(t, !ok)
    }
}

@(test)
test_dynamic_strftime_formats :: proc(t: ^testing.T) {
    // Use UTC time to avoid timezone conversion issues
    parsed, _ := json.parse_string(`{"article": {"date": "2025-06-03T15:30:45Z"}}`)
    defer json.destroy_value(parsed)
    ctx := parsed.(json.Object)

    // Test various format strings
    test_cases := []struct {
        format:   string,
        expected: string,
    } {
        {`strftime("%Y")`, "2025"},
        {`strftime("%m")`, "06"},
        {`strftime("%d")`, "03"},
        {`strftime("%H")`, "15"},
        {`strftime("%M")`, "30"},
        {`strftime("%S")`, "45"},
        {`strftime("%Y-%m-%d")`, "2025-06-03"},
        {`strftime("%H:%M:%S")`, "15:30:45"},
        {`strftime("%Y-%m-%d %H:%M:%S")`, "2025-06-03 15:30:45"},
    }

    for test_case in test_cases {
        result := to_string(
            eval_expr(fmt.aprintf("article.date.%s", test_case.format), &ctx),
        )
        expect_str(t, test_case.expected, result)
    }
}

@(test)
test_strftime_with_locale_c :: proc(t: ^testing.T) {
    libc.setlocale(libc.Locale_Category.ALL, "C")
    defer libc.setlocale(libc.Locale_Category.ALL, "")

    // Use UTC time to avoid timezone issues
    parsed, _ := json.parse_string(`{"article": {"date": "2025-06-03T15:30:45Z"}}`)
    defer json.destroy_value(parsed)
    ctx := parsed.(json.Object)

    // Test with C locale (English)
    expect_str(t, "June", to_string(eval_expr("article.date.strftime(\"%B\")", &ctx)))
    expect_str(t, "Jun", to_string(eval_expr("article.date.strftime(\"%b\")", &ctx)))
    expect_str(t, "Tuesday", to_string(eval_expr("article.date.strftime(\"%A\")", &ctx)))
    expect_str(t, "Tue", to_string(eval_expr("article.date.strftime(\"%a\")", &ctx)))
}

@(test)
test_strftime_with_locale_fr :: proc(t: ^testing.T) {
    libc.setlocale(libc.Locale_Category.ALL, "fr_FR.UTF-8")
    defer libc.setlocale(libc.Locale_Category.ALL, "")

    // Use UTC time to avoid timezone issues
    parsed, _ := json.parse_string(`{"article": {"date": "2025-06-03T15:30:45Z"}}`)
    defer json.destroy_value(parsed)
    ctx := parsed.(json.Object)

    // Test with French locale - these will only work if fr_FR.UTF-8 is available on the system
    result := to_string(eval_expr("article.date.strftime(\"%B\")", &ctx))
    expect_str(t, "juin", result)
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
    result = render_template_string("hello {{   city   }} bye", &country)
    expect_str(t, "hello Paris bye", result)

    result = render_template_string("hello {{ world.country.city }} bye", &ctx)
    expect_str(t, "hello Paris bye", result)

    result = render_template_string("hello {{ world }} bye", &ctx)
    expect_str(t, `hello {"country":{"city":"Paris"}} bye`, result)

    result = render_template_string("hello {{ list }} bye", &ctx)
    expect_str(t, `hello ["um","dois","tres"] bye`, result)

    result = render_template_string("hello [{{ not.valid }}] bye", &ctx)
    expect_str(t, "hello [] bye", result)

    result = render_template_string("hello {{ world.country.city.invalid }} bye", &ctx)
    expect_str(t, "hello  bye", result)
}

@(test)
test_render_template_translation_lang_display :: proc(t: ^testing.T) {
    parsed, _ := json.parse_string(`{"translation": {"lang": "en"}, "lang2": "pt-br"}`)
    defer json.destroy_value(parsed)
    ctx := parsed.(json.Object)

    result: string
    result = render_template_string(
        "Lang: {{ lang_display_name(translation.lang) }}",
        &ctx,
    )
    expect_str(t, "Lang: English", result)

    result = render_template_string("Lang: {{ lang_display_name(lang2) }}", &ctx)
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
        allocator = context.temp_allocator,
    )
    ctx := parsed.(json.Object)

    templ_str: string

    // when:
    templ_str = "{% if article %}{{ article.title }}{% endif %}"
    // then:
    expect_str(t, "One giga monkeys", render_template_string(templ_str, &ctx))

    // when:
    templ_str =
    "{% if nothing %}nothing{% endif %}Article: {% if article %}{{ article.title }}{% endif %}"
    // then:
    expect_str(t, "Article: One giga monkeys", render_template_string(templ_str, &ctx))

    // when:
    templ_str = "{% if nothing %}nothing{% else %}something{% endif %}"
    // then:
    expect_str(t, "something", render_template_string(templ_str, &ctx))

    // when:
    templ_str = "{% if nothing %}nothing{% else %}something{% endif %}"
    // then:
    expect_str(t, "something", render_template_string(templ_str, &ctx))

    // when:
    templ_str = "{% if nothing is defined %}nothing{% else %}something{% endif %}"
    // then:
    expect_str(t, "nothing", render_template_string(templ_str, &ctx))

    // when:
    templ_str = "{% if article %}{{ article.title }}{% else %}no article{% endif %}"
    // then:
    expect_str(t, "One giga monkeys", render_template_string(templ_str, &ctx))

    // when:
    templ_str = `{% if fruit == banana.name %}Bananas for all!{% endif %}`
    // then:
    expect_str(t, "Bananas for all!", render_template_string(templ_str, &ctx))

    // when:
    templ_str =
    `{% if fruit != banana.name %}Bananas for all!{% else %}No bananas{% endif %}`
    // then:
    expect_str(t, "No bananas", render_template_string(templ_str, &ctx))

    // when:
    templ_str =
    `{% if nothing is defined and fruit == banana.name %}Bananas for all!{% endif %}`
    // then:
    expect_str(t, "Bananas for all!", render_template_string(templ_str, &ctx))

    // when:
    templ_str =
    `{% if nothing is defined and fruit == something %}Bananas for all!{% endif %}`
    // then:
    expect_str(t, "", render_template_string(templ_str, &ctx))

    // when:
    templ_str =
    `<h1><a href="{{ SITEURL }}/index.html">{{ SITENAME }} {% if SITESUBTITLE %} <strong>{{ SITESUBTITLE }}</strong>{% endif %}</a></h1>`
    // then:
    expect_str(
        t,
        `<h1><a href="/index.html"> </a></h1>`,
        render_template_string(templ_str, &ctx),
    )

    // and given:
    ctx["SITEURL"] = "http://example.com"

    // when:
    templ_str =
    `<h1><a href="{{ SITEURL }}/index.html">{{ SITENAME }} {% if SITESUBTITLE %} <strong>{{ SITESUBTITLE }}</strong>{% endif %}</a></h1>`
    // then:
    expect_str(
        t,
        `<h1><a href="http://example.com/index.html"> </a></h1>`,
        render_template_string(templ_str, &ctx),
    )

    // when:
    templ_str =
    `{% if FEED_RSS %}<link href="{{ SITEURL }}/{{ FEED_RSS }}" type="application/rss+xml" rel="alternate" title="{{ SITENAME }} RSS Feed" />{% endif %}`
    // then:
    expect_str(t, "", render_template_string(templ_str, &ctx))
}

@(test)
test_render_template_javascript :: proc(t: ^testing.T) {
    ctx: json.Object
    templ_str: string

    // when:
    templ_str = strings.trim_space(
        `
<script>
var host = "eliasdorneles.github.io";
if (window.location.host == host && window.location.protocol != "https:") {
  window.location.protocol = "https:";
}
</script>
        `,
    )
    // then:
    expect_str(t, templ_str, render_template_string(templ_str, &ctx))
}

@(test)
test_parse_template_blocks :: proc(t: ^testing.T) {
    // given:
    templ_str := strings.trim_space(
        `
    {% extends "base.html" %}
    {% block um %}um {% block inner-um %}inner-um{% endblock %} and um{% endblock %}
    {% block dois %}{% if hola %}dois{% endif %}{% endblock %}
    `,
    )
    reader: strings.Reader
    strings.reader_init(&reader, templ_str)

    // when:
    templ_blocks: map[string]string
    defer delete(templ_blocks)

    testing.expect(t, parse_template_blocks(&reader, &templ_blocks))
    expect_str(
        t,
        "um {% block inner-um %}inner-um{% endblock %} and um",
        templ_blocks["um"],
    )
    expect_str(t, "inner-um", templ_blocks["inner-um"])
    expect_str(t, "{% if hola %}dois{% endif %}", templ_blocks["dois"])
}

@(test)
test_parse_template_blocks_with_block_name_in_endblock :: proc(t: ^testing.T) {
    // and given:
    templ_str := strings.trim_space(
        `
    {% extends "base.html" %}
    {% block um %}um {% block inner-um %}inner-um{% endblock inner-um %} and um{% endblock um %}
    {% block dois %}{% if hola %}dois{% endif %}{% endblock dois %}
    `,
    )
    reader: strings.Reader
    strings.reader_init(&reader, templ_str)

    // when:
    templ_blocks: map[string]string
    defer delete(templ_blocks)

    testing.expect(t, parse_template_blocks(&reader, &templ_blocks))
    expect_str(
        t,
        "um {% block inner-um %}inner-um{% endblock inner-um %} and um",
        templ_blocks["um"],
    )
    expect_str(t, "inner-um", templ_blocks["inner-um"])
    expect_str(t, "{% if hola %}dois{% endif %}", templ_blocks["dois"])
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
    expect_str(t, "- Apple- Banana- Kiwi", render_template_string(templ_str, &ctx))

    // and when:
    templ_str =
    "BEGIN {% for it in items %}: {% for x in it.row %}{{ x }}_{% endfor %} AND{% endfor %} END"
    // then:
    expect_str(
        t,
        "BEGIN : a_b_c_ AND: d_e_f_ AND: g_h_i_ AND END",
        render_template_string(templ_str, &ctx),
    )

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
    expect_str(t, expected, render_template_string(templ_str, &ctx))
}

@(test)
test_resolve_template_includes :: proc(t: ^testing.T) {
    // given:
    env: Environment
    env.raw_templates["article.html"] = `<article>{% include "info.html" %}</article>`
    env.raw_templates["info.html"] = "{% block article %}ARTICLE{% endblock %}"
    defer destroy_env(&env)

    // when:
    ok := resolve_template_includes(&env, "article.html")

    // then:
    testing.expect(t, ok)
    expected := "<article>{% block article %}ARTICLE{% endblock %}</article>"
    expect_str(t, expected, env.loaded_templates["article.html"])

    // and when:
    env.raw_templates["page.html"] = `<page>{% include "article.html" %}</page>`
    ok = resolve_template_includes(&env, "page.html")

    // then:
    testing.expect(t, ok)
    expected = "<page><article>{% block article %}ARTICLE{% endblock %}</article></page>"
    expect_str(t, expected, env.loaded_templates["page.html"])
}

@(test)
test_resolve_extends_template :: proc(t: ^testing.T) {
    // given:
    env: Environment
    env.raw_templates["base.html"] = strings.trim_space(
        `
<html>{% block title %}{% if title %}title={{ SITENAME }}{% endif %}{% endblock %}<article>{% block article %}{% endblock %}</article></html>
    `,
    )
    env.raw_templates["article.html"] = strings.trim_space(
        `
{% extends "base.html" %}
{% block article %}ARTICLE{% endblock %}
{% block footer %}NOT USED IN BASE, SHALL BE IGNORED{% endblock %}
    `,
    )
    env.raw_templates["other.html"] = strings.trim_space(
        `
{% extends "base.html" %}
{% block article %}ARTICLE{% endblock %}
{% block title %}hello={{ hello }}{% endblock %}
    `,
    )
    defer destroy_env(&env)

    // when:
    result, ok := resolve_extends_template(&env, "article.html")
    // then:
    testing.expect(t, ok)
    expect_str(
        t,
        "<html>{% if title %}title={{ SITENAME }}{% endif %}<article>ARTICLE</article></html>",
        result,
    )

    // and when:
    result, ok = resolve_extends_template(&env, "other.html")
    // then:
    testing.expect(t, ok)
    expect_str(t, "<html>hello={{ hello }}<article>ARTICLE</article></html>", result)
}

// =================================================================
// NEW TOKENIZER TESTS
// =================================================================

@(test)
test_tokenizer_basic :: proc(t: ^testing.T) {
    // Test simple text
    tokenizer := init_tokenizer("hello world")
    token := next_token(&tokenizer)
    testing.expect(t, token.type == .TEXT)
    testing.expect(t, token.value == "hello world")
    testing.expect(t, token.line == 1)
    testing.expect(t, token.column == 1)

    // EOF token
    token = next_token(&tokenizer)
    testing.expect(t, token.type == .EOF)
}

@(test)
test_tokenizer_expression :: proc(t: ^testing.T) {
    tokenizer := init_tokenizer("Hello {{ name }} world")

    // First token: text
    token := next_token(&tokenizer)
    testing.expect(t, token.type == .TEXT)
    testing.expect(t, token.value == "Hello ")

    // Second token: expression
    token = next_token(&tokenizer)
    testing.expect(t, token.type == .EXPRESSION)
    testing.expect(t, token.value == "name")

    // Third token: text
    token = next_token(&tokenizer)
    testing.expect(t, token.type == .TEXT)
    testing.expect(t, token.value == " world")

    // EOF
    token = next_token(&tokenizer)
    testing.expect(t, token.type == .EOF)
}

@(test)
test_tokenizer_statement :: proc(t: ^testing.T) {
    tokenizer := init_tokenizer("{% if condition %}content{% endif %}")

    // First token: statement
    token := next_token(&tokenizer)
    testing.expect(t, token.type == .STATEMENT)
    testing.expect(t, token.value == "if condition")

    // Second token: text
    token = next_token(&tokenizer)
    testing.expect(t, token.type == .TEXT)
    testing.expect(t, token.value == "content")

    // Third token: statement
    token = next_token(&tokenizer)
    testing.expect(t, token.type == .STATEMENT)
    testing.expect(t, token.value == "endif")

    // EOF
    token = next_token(&tokenizer)
    testing.expect(t, token.type == .EOF)
}

@(test)
test_tokenizer_mixed_content :: proc(t: ^testing.T) {
    tokenizer := init_tokenizer(
        "Before {{ var }} middle {% if test %} inside {% endif %} after",
    )

    tokens: [dynamic]Token
    defer delete(tokens)

    for {
        token := next_token(&tokenizer)
        append(&tokens, token)
        if token.type == .EOF {
            break
        }
    }

    testing.expect(t, len(tokens) == 8) // 7 tokens + EOF
    testing.expect(t, tokens[0].type == .TEXT && tokens[0].value == "Before ")
    testing.expect(t, tokens[1].type == .EXPRESSION && tokens[1].value == "var")
    testing.expect(t, tokens[2].type == .TEXT && tokens[2].value == " middle ")
    testing.expect(t, tokens[3].type == .STATEMENT && tokens[3].value == "if test")
    testing.expect(t, tokens[4].type == .TEXT && tokens[4].value == " inside ")
    testing.expect(t, tokens[5].type == .STATEMENT && tokens[5].value == "endif")
    testing.expect(t, tokens[6].type == .TEXT && tokens[6].value == " after")
    testing.expect(t, tokens[7].type == .EOF)
}

@(test)
test_tokenizer_line_tracking :: proc(t: ^testing.T) {
    tokenizer := init_tokenizer("line1\n{{ var }}\nline3")

    // First token: "line1\n"
    token := next_token(&tokenizer)
    testing.expect(t, token.type == .TEXT)
    testing.expect(t, token.line == 1)
    testing.expect(t, token.column == 1)

    // Second token: expression on line 2
    token = next_token(&tokenizer)
    testing.expect(t, token.type == .EXPRESSION)
    testing.expect(t, token.line == 2)
    testing.expect(t, token.column == 1)

    // Third token: remaining text
    token = next_token(&tokenizer)
    testing.expect(t, token.type == .TEXT)
    testing.expect(t, token.line == 2)
}

@(test)
test_tokenizer_malformed_expression :: proc(t: ^testing.T) {
    tokenizer := init_tokenizer("{{ unclosed")

    // Should treat as text when malformed - first token is "{"
    token := next_token(&tokenizer)
    testing.expect(t, token.type == .TEXT)
    testing.expect(t, token.value == "{")

    // Second token is the rest of the content
    token = next_token(&tokenizer)
    testing.expect(t, token.type == .TEXT)
    testing.expect(t, token.value == "{ unclosed")

    // EOF
    token = next_token(&tokenizer)
    testing.expect(t, token.type == .EOF)
}

// =================================================================
// NEW PARSER V2 TESTS
// =================================================================

@(test)
test_render_template_simple_expr_v2 :: proc(t: ^testing.T) {
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
    result = render_template_string_v2("hello {{   city   }} bye", &country)
    expect_str(t, "hello Paris bye", result)

    result = render_template_string_v2("hello {{ world.country.city }} bye", &ctx)
    expect_str(t, "hello Paris bye", result)

    result = render_template_string_v2("hello {{ world }} bye", &ctx)
    expect_str(t, `hello {"country":{"city":"Paris"}} bye`, result)

    result = render_template_string_v2("hello {{ list }} bye", &ctx)
    expect_str(t, `hello ["um","dois","tres"] bye`, result)

    result = render_template_string_v2("hello [{{ not.valid }}] bye", &ctx)
    expect_str(t, "hello [] bye", result)

    result = render_template_string_v2(
        "hello {{ world.country.city.invalid }} bye",
        &ctx,
    )
    expect_str(t, "hello  bye", result)
}

@(test)
test_render_template_translation_lang_display_v2 :: proc(t: ^testing.T) {
    parsed, _ := json.parse_string(`{"translation": {"lang": "en"}, "lang2": "pt-br"}`)
    defer json.destroy_value(parsed)
    ctx := parsed.(json.Object)

    result: string
    result = render_template_string_v2(
        "Lang: {{ lang_display_name(translation.lang) }}",
        &ctx,
    )
    expect_str(t, "Lang: English", result)

    result = render_template_string_v2("Lang: {{ lang_display_name(lang2) }}", &ctx)
    expect_str(t, "Lang: Português (Brasil)", result)
}

@(test)
test_render_template_if_v2 :: proc(t: ^testing.T) {
    // given:
    parsed, _ := json.parse_string(
        `{
            "article": {"title":  "One giga monkeys"},
            "nothing": false,
            "fruit": "Banana",
            "banana": {"name": "Banana"}
         }`,
        allocator = context.temp_allocator,
    )
    ctx := parsed.(json.Object)

    templ_str: string

    // when:
    templ_str = "{% if article %}{{ article.title }}{% endif %}"
    // then:
    expect_str(t, "One giga monkeys", render_template_string_v2(templ_str, &ctx))

    // when:
    templ_str =
    "{% if nothing %}nothing{% endif %}Article: {% if article %}{{ article.title }}{% endif %}"
    // then:
    expect_str(
        t,
        "Article: One giga monkeys",
        render_template_string_v2(templ_str, &ctx),
    )

    // when:
    templ_str = "{% if nothing %}nothing{% else %}something{% endif %}"
    // then:
    expect_str(t, "something", render_template_string_v2(templ_str, &ctx))

    // when:
    templ_str = "{% if nothing is defined %}nothing{% else %}something{% endif %}"
    // then:
    expect_str(t, "nothing", render_template_string_v2(templ_str, &ctx))

    // when:
    templ_str = "{% if article %}{{ article.title }}{% else %}no article{% endif %}"
    // then:
    expect_str(t, "One giga monkeys", render_template_string_v2(templ_str, &ctx))

    // when:
    templ_str = `{% if fruit == banana.name %}Bananas for all!{% endif %}`
    // then:
    expect_str(t, "Bananas for all!", render_template_string_v2(templ_str, &ctx))

    // when:
    templ_str =
    `{% if fruit != banana.name %}Bananas for all!{% else %}No bananas{% endif %}`
    // then:
    expect_str(t, "No bananas", render_template_string_v2(templ_str, &ctx))

    // when:
    templ_str =
    `{% if nothing is defined and fruit == banana.name %}Bananas for all!{% endif %}`
    // then:
    expect_str(t, "Bananas for all!", render_template_string_v2(templ_str, &ctx))

    // when:
    templ_str =
    `{% if nothing is defined and fruit == something %}Bananas for all!{% endif %}`
    // then:
    expect_str(t, "", render_template_string_v2(templ_str, &ctx))

    // when:
    templ_str =
    `<h1><a href="{{ SITEURL }}/index.html">{{ SITENAME }} {% if SITESUBTITLE %} <strong>{{ SITESUBTITLE }}</strong>{% endif %}</a></h1>`
    // then:
    expect_str(
        t,
        `<h1><a href="/index.html"> </a></h1>`,
        render_template_string_v2(templ_str, &ctx),
    )

    // and given:
    ctx["SITEURL"] = "http://example.com"

    // when:
    templ_str =
    `<h1><a href="{{ SITEURL }}/index.html">{{ SITENAME }} {% if SITESUBTITLE %} <strong>{{ SITESUBTITLE }}</strong>{% endif %}</a></h1>`
    // then:
    expect_str(
        t,
        `<h1><a href="http://example.com/index.html"> </a></h1>`,
        render_template_string_v2(templ_str, &ctx),
    )

    // when:
    templ_str =
    `{% if FEED_RSS %}<link href="{{ SITEURL }}/{{ FEED_RSS }}" type="application/rss+xml" rel="alternate" title="{{ SITENAME }} RSS Feed" />{% endif %}`
    // then:
    expect_str(t, "", render_template_string_v2(templ_str, &ctx))
}

@(test)
test_render_template_javascript_v2 :: proc(t: ^testing.T) {
    ctx: json.Object
    templ_str: string

    // when:
    templ_str = strings.trim_space(
        `
<script>
var host = "eliasdorneles.github.io";
if (window.location.host == host && window.location.protocol != "https:") {
  window.location.protocol = "https:";
}
</script>
        `,
    )
    // then:
    expect_str(t, templ_str, render_template_string_v2(templ_str, &ctx))
}

@(test)
test_render_template_for_v2 :: proc(t: ^testing.T) {
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

    // Test simple for loop first
    templ_str = "{% for it in items %}- {{ it.name }}{% endfor %}"
    result := render_template_string_v2(templ_str, &ctx)
    expect_str(t, "- Apple- Banana- Kiwi", result)
}

// Compatibility test: compare old vs new parser output
@(test)
test_parser_compatibility :: proc(t: ^testing.T) {
    // Test various template patterns to ensure v2 produces same results as v1
    parsed, _ := json.parse_string(
        `{
            "name": "John",
            "age": 30,
            "items": [{"title": "Item1"}, {"title": "Item2"}],
            "active": true,
            "inactive": false
        }`,
    )
    defer json.destroy_value(parsed)
    ctx := parsed.(json.Object)

    test_cases := []string {
        "Hello {{ name }}!",
        "{{ name }} is {{ age }} years old",
        "{% if active %}Active{% else %}Inactive{% endif %}",
        "{% if inactive %}Hidden{% endif %}Visible",
        "{% for item in items %}{{ item.title }}, {% endfor %}",
        "Mixed: {{ name }} {% if active %}is active{% endif %}!",
    }

    for test_case in test_cases {
        result_v1 := render_template_string(test_case, &ctx)
        result_v2 := render_template_string_v2(test_case, &ctx)

        testing.expectf(
            t,
            result_v1 == result_v2,
            "Parser v2 output differs from v1 for template: %s\nv1: %s\nv2: %s",
            test_case,
            result_v1,
            result_v2,
        )
    }
}
