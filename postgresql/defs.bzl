"Public API re-exports"

load("@aspect_bazel_lib//lib:expand_make_vars.bzl", "expand_locations", "expand_variables")

def _postgres_server_test_impl(ctx):
    fixed_args = ctx.attr.fixed_args
    postgresqlinfo = ctx.toolchains["//postgresql:toolchain_type"].postgresqlinfo

    executable = ctx.actions.declare_file(
        ctx.label.name + "_wrapper.sh",
    )

    fixed_args_expanded = [expand_variables(ctx, expand_locations(ctx, fixed_arg, ctx.attr.data)) for fixed_arg in fixed_args]

    cmd = ctx.attr.cmd if ctx.attr.cmd else """exec {binary} {fixed_args} $@""".format(
        binary = ctx.executable.binary.path,
        fixed_args = " ".join(fixed_args_expanded),
    )

    args = ctx.actions.args()
    args.add_all(fixed_args_expanded)

    #expand_variables(ctx, s, outs, attribute_name)
    ctx.actions.write(
        output = executable,
        content = """#!/bin/bash
cd $(dirname {binary})

# Set this so that we do not use Unix sockets
export PGHOST=localhost
{env}

pg_ctl --version

pg_ctl init -D $TEST_TMPDIR/postgres
pg_ctl start -w -D $TEST_TMPDIR/postgres

createuser -s postgres

{cmd}
res=$?

pg_ctl stop -D $TEST_TMPDIR/postgres

exit $res
        """.format(
            binary = postgresqlinfo.target_tool_path,
            cmd = cmd,
            env = " ".join(["export {}=\"{}\"".format(key, value) for (key, value) in ctx.attr.env.items()]),
        ),
        is_executable = True,
    )

    inputs = postgresqlinfo.tool_files

    return [
        DefaultInfo(
            executable = executable,
            runfiles = ctx.runfiles(
                files = [executable],
                transitive_files = depset(inputs),
            ),
        ),
    ]

postgres_server_test = rule(
    implementation = _postgres_server_test_impl,
    doc = """Provides runnable Postgres wrapper script and providers for a root module.

This rule waits for the Postgres server to be ready before running the script.
    """,
    attrs = {
        "binary": attr.label(
            executable = True,
            allow_files = True,
            cfg = "exec",
            doc = """The Postgres binary to use.""",
        ),
        "cmd": attr.string(
            default = "",
            doc = """The command to run.""",
        ),
        "data": attr.label_list(
            allow_files = True,
        ),
        "env": attr.string_dict(
            default = {},
            doc = """Environment variables to set for the Postgres server.""",
        ),
        "fixed_args": attr.string_list(
            default = [],
            doc = """Arguments to pass to the Postgres server.""",
        ),
    },
    toolchains = ["//postgresql:toolchain_type"],
    executable = False,
    test = True,
)
