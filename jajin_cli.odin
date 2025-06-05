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

from_json_value_to_sitegen_value :: proc(json_val: json.Value) -> sitegen.Value {
    switch val in json_val {
    case json.Null, json.Integer, json.Float, json.Boolean:
        return nil // null, numeric types and boolean aren't supported
    case json.String:
        return cast(sitegen.Value)val
    case json.Array:
        return from_json_array_to_sitegen_list(val)
    case json.Object:
        return from_json_to_sitegen_ctx(val)
    }
    return nil
}

from_json_array_to_sitegen_list :: proc(json_arr: json.Array) -> sitegen.List {
    list: [dynamic]sitegen.Value
    for item in json_arr {
        append(&list, from_json_value_to_sitegen_value(item))
    }
    return list[:]
}

from_json_to_sitegen_ctx :: proc(json_obj: json.Object) -> sitegen.Context {
    ctx := make(sitegen.Context, allocator = context.temp_allocator)
    for key, val in json_obj {
        ctx[key] = from_json_value_to_sitegen_value(val)
    }
    return ctx
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
    ctx := from_json_to_sitegen_ctx(context_dict.(json.Object))
    rendered_output := sitegen.render_template(template_str, &ctx)
    fmt.println(rendered_output)
}
