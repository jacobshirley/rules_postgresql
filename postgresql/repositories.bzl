"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//postgresql/private:toolchains_repo.bzl", "PLATFORMS", "toolchains_repo")
load("//postgresql/private:versions.bzl", "TOOL_VERSIONS")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
# This is all fixed by bzlmod, so we just tolerate it for now.
def rules_postgresql_dependencies():
    # The minimal version of bazel_skylib we require
    http_archive(
        name = "bazel_skylib",
        sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
        ],
    )

    http_archive(
        name = "rules_foreign_cc",
        strip_prefix = "rules_foreign_cc-ef3031e3874b8282c717fd3341ef5fbad2591b8f",
        url = "https://github.com/bazelbuild/rules_foreign_cc/archive/ef3031e3874b8282c717fd3341ef5fbad2591b8f.zip",
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "91acfc0ef798d3c87639cbfdb6274845ad70edbddfd92e49ac70944f08f97f58",
        strip_prefix = "bazel-lib-2.0.0-rc0",
        url = "https://github.com/aspect-build/bazel-lib/releases/download/v2.0.0-rc0/bazel-lib-v2.0.0-rc0.tar.gz",
    )

########
# Remaining content of the file is only used to support toolchains.
########
_DOC = "Fetch external tools needed for postgresql toolchain"
_ATTRS = {
    "postgresql_version": attr.string(mandatory = True, values = TOOL_VERSIONS.keys()),
    "platform": attr.string(mandatory = True, values = PLATFORMS.keys()),
    "_build_tpl": attr.label(
        default = Label("@rules_postgresql//postgresql:BUILD.postgres.tpl.bazel"),
        allow_single_file = True,
    ),
}

# TODO: add these to the toolchain
LINUX_LIBS = {
    "linux_arm64": [
        #TODO: include libssl here
        #TODO: include zlib here
        # https://packages.ubuntu.com/focal/arm64/libicu66/download
        (
            "6302e309ab002af30ddfa0d68de26c68f7c034ed2f45b1d97a712bff1a03999a",
            "http://ports.ubuntu.com/pool/main/i/icu/libicu66_66.1-2ubuntu2_arm64.deb",
        ),
    ],
    "linux_amd64": [
        #TODO: include libssl here
        #TODO: include zlib here
        # https://packages.ubuntu.com/focal/amd64/libicu66/download
        (
            "00d0de456134668f41bd9ea308a076bc0a6a805180445af8a37209d433f41efe",
            "http://security.ubuntu.com/ubuntu/pool/main/i/icu/libicu66_66.1-2ubuntu2.1_amd64.deb",
        ),
    ],
}

def _postgresql_repo_impl(repository_ctx):
    rel = repository_ctx.attr.postgresql_version.replace(".", "_")
    url = "https://github.com/postgres/postgres/archive/refs/tags/REL_{}.tar.gz".format(
        rel,
    )
    repository_ctx.download_and_extract(
        url = url,
        integrity = TOOL_VERSIONS[repository_ctx.attr.postgresql_version],
    )

    # Base BUILD file for this repository
    repository_ctx.template(
        "BUILD",
        repository_ctx.attr._build_tpl,
        substitutions = {
            "{version}": rel,
        },
    )

postgresql_repositories = repository_rule(
    _postgresql_repo_impl,
    doc = _DOC,
    attrs = _ATTRS,
)

# Wrapper macro around everything above, this is the primary API
def postgresql_register_toolchains(name, register = True, **kwargs):
    """Convenience macro for users which does typical setup.

    - create a repository for each built-in platform like "postgresql_linux_amd64" -
      this repository is lazily fetched when node is needed for that platform.
    - TODO: create a convenience repository for the host platform like "postgresql_host"
    - create a repository exposing toolchains for each platform like "postgresql_platforms"
    - register a toolchain pointing at each platform
    Users can avoid this macro and do these steps themselves, if they want more control.
    Args:
        name: base name for all created repos, like "postgresql1_14"
        register: whether to call through to native.register_toolchains.
            Should be True for WORKSPACE users, but false when used under bzlmod extension
        **kwargs: passed to each node_repositories call
    """
    for platform in PLATFORMS.keys():
        postgresql_repositories(
            name = name + "_" + platform,
            platform = platform,
            **kwargs
        )
        if register:
            native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))

    toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )
