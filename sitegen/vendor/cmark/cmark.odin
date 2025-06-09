/*
	Stolen snippets from Odin/vendor/commonmark/cmark.odin and adapted to use
	cmark-gfm which adds Github Flavored Markdown
*/
package vendor_commonmark

import "base:runtime"
import "core:c"

foreign import lib "system:cmark-gfm"

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

// Simple API
@(default_calling_convention = "c", link_prefix = "cmark_")
foreign lib {
    // Convert 'text' (assumed to be a UTF-8 encoded string with length `len`) from CommonMark Markdown to HTML
    // returning a null-terminated, UTF-8-encoded string. It is the caller's responsibility
    // to free the returned buffer.
    markdown_to_html :: proc(text: cstring, length: c.size_t, options: Options) -> (html: cstring) ---
}

markdown_to_html_from_string :: proc(text: string, options: Options) -> (html: string) {
    return string(markdown_to_html(cstring(raw_data(text)), len(text), options))
}
