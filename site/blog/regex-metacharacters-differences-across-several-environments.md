Title: Regex metacharacters differences across several environments
Date: 2015-12-13 02:16
Author: Elias Dorneles
Status: published

<!-- PELICAN_BEGIN_SUMMARY -->
Here is a table helpful for learning regular expression metacharacters
differences across several languages and environments.
<!-- PELICAN_END_SUMMARY -->


| Language/environment | Optional  | More  | Brackets  | Border | Or | Group  |
|---------------------:|-----------|-------|-----------|--------|----|--------|
| Apache, Bash, egrep, Java, JS, Perl, PHP, Python, Ruby, VBScript, .NET | `?`   | `+`  | `{,}` | `\b`  | <code>&#124;</code>   | `()` |
| Gawk, Openffice.org | `?`   | `+`   | `{,}` | `\<,\>`   | <code>&#124;</code>   | `()` |
| awk, Mawk, Expect   | `?`   | `+`   | N/A    | N/A    | <code>&#124;</code>   | `()` |
| C, Lex, Tcl | `?`   | `+`   | `{,}` | N/A    | <code>&#124;</code>   | `()` |
| Find, Emacs | `?`   | `+`   | N/A    | `\b`  | <code>\&#124;</code>  | `\(\)` |
| grep, ed    | `\?`  | `\+`  | `\{,\}`   | `\b`  | <code>\&#124;</code>  | `\(\)` |
| sed | `\?`  | `\+`  | `\{,\}`   | `\<,\>`   | <code>\&#124;</code>  | `\(\)` |
| Vim | `\=`  | `\+`  | `\{,}`    | `\<,\>`   | <code>\&#124;</code>  | `\(\)` |
| PostgreSQL | `?`   | `+`  | `{,}` | `\y`  | <code>&#124;</code>   | `()` |
| MySQL | `?`   | `+`  | `{,}` | `[[:<:]]`  | <code>&#124;</code>   | `()` |
| Oracle | `?`   | `+`  | `{,}` | N/A  | <code>&#124;</code>   | `()` |

Thankfully, `.` `*` `[]` `[^]` `^` and `$` work the same way in all.

The hard work of checking the differences was done by [Aurelio
Jargas](http://aurelio.net/), published in [his wonderful book about regular
expressions](http://www.piazinho.com.br/). (Portuguese only)

I merely grouped them by language/environment, chunking the information for
easier memorizing.
