"""This module implements an alias rule to the resolved toolchain.
"""

DOC = """\\\r
Exposes a concrete toolchain which is the result of Bazel resolving the\r
toolchain for the execution or target platform.\r
Workaround for https://github.com/bazelbuild/bazel/issues/14009\r
"""

# Forward all the providers
def _resolved_toolchain_impl(ctx):
    toolchain_info = ctx.toolchains["//postgresql:toolchain_type"]
    return [
        toolchain_info,
        toolchain_info.default,
        toolchain_info.postgresqlinfo,
        toolchain_info.template_variables,
    ]

# Copied from java_toolchain_alias
# https://cs.opensource.google/bazel/bazel/+/master:tools/jdk/java_toolchain_alias.bzl
resolved_toolchain = rule(
    implementation = _resolved_toolchain_impl,
    toolchains = ["//postgresql:toolchain_type"],
    incompatible_use_toolchain_transition = True,
    doc = DOC,
)
