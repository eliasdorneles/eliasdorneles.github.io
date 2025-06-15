/*
Minimal wrapper for CMark-GFM (https://github.com/github/cmark-gfm)

This is adapted from the Odin-vendored CMark bindings available here:
https://github.com/odin-lang/Odin/blob/master/vendor/commonmark/
*/
package vendor_cmark_gfm

import "core:c"
import "core:c/libc"
import "core:log"
import "core:strings"

foreign import lib "system:cmark-gfm"
foreign import lib_ext "system:cmark-gfm-extensions"

Option :: enum c.int {
    Source_Position = 1, // Include a `data-sourcepos` attribute on all block elements.
    Hard_Breaks     = 2, // Render `softbreak` as hard line breaks.
    Safe            = 3, // Defined for API compatibility, now enabled by default.
    Unsafe          = 17, // Render raw HTML and unsafe links (`javascript:`, `vbscript:`,
    // `file:`, and `data:`, except for `image/png`, `image/gif`,
    // `image/jpeg`, or `image/webp` mime types).  By default,
    // raw HTML is replaced by a placeholder HTML comment. Unsafe
    // links are replaced by empty strings.
    No_Breaks       = 4, // Render `softbreak` elements as spaces.
    Normalize       = 8, // Legacy option, no effect.
    Validate_UTF8   = 9, // Validate UTF-8 input before parsing, replacing illegal
    // sequences with the replacement character U+FFFD.
    Smart           = 10, // Convert straight quotes to curly, --- to em dashes, -- to en dashes.
}
Options :: bit_set[Option;c.int]

DEFAULT_OPTIONS :: Options{}

@(default_calling_convention = "c", link_prefix = "cmark_")
foreign lib {
    parser_new :: proc(options: Options) -> rawptr ---
    parser_feed :: proc(parser: rawptr, text: cstring, length: c.size_t) ---
    parser_finish :: proc(parser: rawptr) -> rawptr ---
    render_html :: proc(document: rawptr, options: Options, extensions: rawptr) -> cstring ---
    node_free :: proc(node: rawptr) ---
    parser_free :: proc(parser: rawptr) ---
}

@(default_calling_convention = "c", link_prefix = "cmark_")
foreign lib_ext {
    // Extension management
    gfm_core_extensions_ensure_registered :: proc() ---
    find_syntax_extension :: proc(name: cstring) -> rawptr ---
    parser_attach_syntax_extension :: proc(parser: rawptr, extension: rawptr) -> bool ---
}


@(private = "file")
enable_extension :: proc(parser: rawptr, ext_name: cstring) -> bool {
    if table_ext := find_syntax_extension(ext_name); table_ext != nil {
        parser_attach_syntax_extension(parser, table_ext) or_return
    }
    return true
}

markdown_to_html_from_string :: proc(
    text: string,
    options: Options = DEFAULT_OPTIONS,
) -> (
    html: string,
) {
    gfm_core_extensions_ensure_registered()

    parser := parser_new(options)
    defer parser_free(parser)

    enable_extension(parser, "table")
    enable_extension(parser, "strikethrough")

    // Parse the markdown
    parser_feed(parser, strings.unsafe_string_to_cstring(text), len(text))
    document := parser_finish(parser)
    defer node_free(document)

    // Render to HTML
    html_cstr := render_html(document, options, c.NULL)
    defer libc.free(rawptr(html_cstr)) // <-- not sure why it's segfaulting here =/

    return strings.clone_from_cstring(html_cstr)
}
