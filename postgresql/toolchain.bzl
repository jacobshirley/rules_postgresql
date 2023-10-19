"""This module implements the language-specific toolchain rule.
"""

PostgresqlInfo = provider(
    doc = "Information about how to invoke the tool executable.",
    fields = {
        "target_tool_path": "Path to the tool executable for the target platform.",
        "tool_files": """Files required in runfiles to make the tool executable available.

May be empty if the target_tool_path points to a locally installed tool binary.""",
    },
)

# Avoid using non-normalized paths (workspace/../other_workspace/path)
def _to_manifest_path(ctx, file):
    if file.short_path.startswith("../"):
        return "external/" + file.short_path[3:]
    else:
        return ctx.workspace_name + "/" + file.short_path

def _postgresql_toolchain_impl(ctx):
    if ctx.attr.target_tool and ctx.attr.target_tool_path:
        fail("Can only set one of target_tool or target_tool_path but both were set.")
    if not ctx.attr.target_tool and not ctx.attr.target_tool_path:
        fail("Must set one of target_tool or target_tool_path.")

    target_tool_path = ctx.attr.target_tool_path
    tool_files = []

    if ctx.attr.target_tool:
        tool_files = ctx.attr.target_tool.files.to_list() + ctx.files.data

        target_tool_path = _to_manifest_path(ctx, tool_files[0])
        for file in tool_files:
            if file.short_path.endswith(ctx.attr.binary):
                target_tool_path = _to_manifest_path(ctx, file)

    # Make the $(tool_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "postgresql_BIN": target_tool_path,
    })
    default = DefaultInfo(
        files = depset(tool_files),
        runfiles = ctx.runfiles(files = tool_files),
    )
    postgresqlinfo = PostgresqlInfo(
        target_tool_path = target_tool_path,
        tool_files = tool_files,
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        postgresqlinfo = postgresqlinfo,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

postgresql_toolchain = rule(
    implementation = _postgresql_toolchain_impl,
    attrs = {
        "binary": attr.string(
            doc = "The PATH environment variable to use when invoking the tool.",
            mandatory = False,
            default = "bin/pg_ctl",
        ),
        "target_tool": attr.label(
            doc = "A hermetically downloaded executable target for the target platform.",
            mandatory = False,
            allow_files = True,
        ),
        "target_tool_path": attr.string(
            doc = "Path to an existing executable for the target platform.",
            mandatory = False,
        ),
        "data": attr.label_list(
            doc = "Files required in runfiles to make the tool executable available.",
            mandatory = False,
            allow_files = True,
        ),
    },
    doc = """Defines a postgresql compiler/runtime toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
