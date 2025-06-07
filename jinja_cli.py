import argparse
import json
import jinja2


def render_template(template_str, context):
    template = jinja2.Template(template_str)
    return template.render(context)


def main(args):
    with open(args.template_file, "r") as file:
        template_str = file.read()

    with open(args.context_file, "r") as file:
        context = json.load(file)

    rendered_output = render_template(template_str, context)

    if args.output_file:
        with open(args.output_file, "w") as file:
            file.write(rendered_output)
        print(f"Rendered output saved to {args.output_file}")
    else:
        print(rendered_output)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Render a Jinja2 template with a context."
    )
    parser.add_argument("template_file", help="Path to the Jinja2 template file.")
    parser.add_argument(
        "context_file", help="Path to the JSON file containing the context."
    )
    parser.add_argument(
        "-o",
        "--output_file",
        help="Optional path to save the rendered output. If not provided, output will be printed to stdout.",
    )
    args = parser.parse_args()
    main(args)
