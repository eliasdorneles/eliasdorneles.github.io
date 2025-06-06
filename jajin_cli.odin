package jajin_cli

import "core:encoding/json"
import "core:flags"
import "core:fmt"
import "core:os"
import "core:strings"
import "./sitegen"

Args :: struct {
    template_file: string `args:"pos=0,required" usage:"Path to template file"`,
    context_file:  string `args:"pos=1,required" usage:"Path to JSON file containing context"`,
    output:        string `usage:"Output file"`,
}

main :: proc() {
    args: Args
    flags.parse_or_exit(&args, os.args, style = .Unix)
    template_str: string
    if template_data, ok := os.read_entire_file(args.template_file); ok {
        template_str = strings.clone_from_bytes(template_data)
    } else {
        fmt.eprintf("Couldn't read file %s, exiting", args.template_file)
        os.exit(1)
    }

    context_dict: json.Value
    err: json.Error
    if context_data, ok := os.read_entire_file(args.context_file); ok {
        context_dict, err = json.parse(context_data)
        if err != nil {
            fmt.eprintf("Couldn't load JSON from file %s, exiting", args.context_file)
            os.exit(1)
        }
    } else {
        fmt.eprintf("Couldn't read file %s, exiting", args.context_file)
        os.exit(1)
    }
    ctx := context_dict.(json.Object)
    rendered_output := sitegen.render_template(template_str, &ctx)
    fmt.println(rendered_output)
}
