package jajin_cli

import "./sitegen"
import "core:encoding/json"
import "core:flags"
import "core:fmt"
import "core:os"
import "core:strings"


Args :: struct {
    template_name: string `args:"pos=0,required" usage:"Template name"`,
    context_file:  string `args:"pos=1,required" usage:"Path to JSON file containing context"`,
    output:        string `usage:"Output file"`,
}

main :: proc() {
    args: Args
    flags.parse_or_exit(&args, os.args, style = .Unix)
    env: sitegen.Environment

    if !sitegen.load_template(&env, args.template_name) {
        fmt.eprintf("Couldn't load template %s, exiting", args.template_name)
        os.exit(1)
    }

    context_dict: json.Value
    if context_data, ok := os.read_entire_file(args.context_file); ok {
        err: json.Error
        if context_dict, err = json.parse(context_data); err != nil {
            fmt.eprintf("Couldn't load JSON from file %s, exiting", args.context_file)
            os.exit(1)
        }
    } else {
        fmt.eprintf("Couldn't read file %s, exiting", args.context_file)
        os.exit(1)
    }

    ctx := context_dict.(json.Object)
    rendered_output, ok := sitegen.render_template(&env, args.template_name, &ctx)

    if ok {
        fmt.println(rendered_output)
    } else {
        fmt.eprintln("Error attempting to render template")
    }
}
