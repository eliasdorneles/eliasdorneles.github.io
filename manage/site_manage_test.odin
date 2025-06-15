package site_manage

import "core:strings"
import "core:testing"

@(test)
test_gen_article_filename_basic :: proc(t: ^testing.T) {
    title := "Hello World"
    articles_dir := "site/blog"
    expected := "site/blog/hello-world.md"

    result := gen_article_filename(title, articles_dir)
    defer delete(result)
    testing.expect_value(t, result, expected)
}

@(test)
test_gen_article_filename_special_chars :: proc(t: ^testing.T) {
    title := "Hello! @World# 123"
    articles_dir := "site/blog"
    expected := "site/blog/hello-world-123.md"

    result := gen_article_filename(title, articles_dir)
    defer delete(result)
    testing.expect_value(t, result, expected)
}

@(test)
test_gen_article_filename_unicode :: proc(t: ^testing.T) {
    title := "Olá Coração"
    articles_dir := "site/blog"
    expected := "site/blog/ola-coracao.md"

    result := gen_article_filename(title, articles_dir)
    defer delete(result)
    testing.expect_value(t, result, expected)
}

@(test)
test_gen_article_filename_multiple_spaces :: proc(t: ^testing.T) {
    title := "Hello   World"
    articles_dir := "site/blog"
    expected := "site/blog/hello-world.md"

    result := gen_article_filename(title, articles_dir)
    defer delete(result)
    testing.expect_value(t, result, expected)
}

@(test)
test_gen_article_filename_empty_title :: proc(t: ^testing.T) {
    title := ""
    articles_dir := "site/blog"
    expected := "site/blog/.md"

    result := gen_article_filename(title, articles_dir)
    defer delete(result)
    testing.expect_value(t, result, expected)
}

@(test)
test_gen_article_filename_empty_dir :: proc(t: ^testing.T) {
    title := "Hello World"
    articles_dir := ""
    expected := "hello-world.md"

    result := gen_article_filename(title, articles_dir)
    defer delete(result)
    testing.expect_value(t, result, expected)
}

