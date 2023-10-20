"""Register toolchains for postgresql.
"""

load("//postgresql/private:toolchains_repo.bzl", "PLATFORMS", "toolchains_repo")
load("//postgresql/private:versions.bzl", "TOOL_VERSIONS")
load("@aspect_bazel_lib//lib:repo_utils.bzl", "repo_utils")

########
# Remaining content of the file is only used to support toolchains.
########
_DOC = "Fetch external tools needed for postgresql toolchain"
_ATTRS = {
    "platform": attr.string(mandatory = True, values = PLATFORMS.keys()),
    "postgresql_version": attr.string(mandatory = True, values = TOOL_VERSIONS.keys()),
    "_build_tpl": attr.label(
        default = Label("@rules_postgresql//postgresql:BUILD.postgres.tpl.bazel"),
        allow_single_file = True,
    ),
}

# TODO: add these to the toolchain
LINUX_LIBS = {
    "linux_amd64": [
        #TODO: include libssl here
        #TODO: include zlib here
        # https://packages.ubuntu.com/focal/amd64/libicu66/download
        (
            "00d0de456134668f41bd9ea308a076bc0a6a805180445af8a37209d433f41efe",
            "http://security.ubuntu.com/ubuntu/pool/main/i/icu/libicu66_66.1-2ubuntu2.1_amd64.deb",
        ),
    ],
    "linux_arm64": [
        #TODO: include libssl here
        #TODO: include zlib here
        # https://packages.ubuntu.com/focal/arm64/libicu66/download
        (
            "6302e309ab002af30ddfa0d68de26c68f7c034ed2f45b1d97a712bff1a03999a",
            "http://ports.ubuntu.com/pool/main/i/icu/libicu66_66.1-2ubuntu2_arm64.deb",
        ),
    ],
}

def _postgresql_repo_impl(repository_ctx):
    platform = repository_ctx.attr.platform
    version = repository_ctx.attr.postgresql_version
    if (repo_utils.is_windows(repository_ctx)):
        url = "https://get.enterprisedb.com/postgresql/postgresql-{version}-1-windows-x64-binaries.zip".format(
            version = version,
        )
        repository_ctx.download_and_extract(
            url = url,
            integrity = TOOL_VERSIONS[repository_ctx.attr.postgresql_version]["bin"][platform],
        )

        repository_ctx.file(
            "BUILD",
            content = """

# This is a generated file, do not edit.

load("@rules_postgresql//postgresql:toolchain.bzl", "postgresql_toolchain")

filegroup(
    name = "postgresql_build",
    srcs = glob(["pgsql/**/*"]),
)

postgresql_toolchain(
    name = "postgresql_toolchain", 
    binary = "bin/pg_ctl.exe",
    target_tool = ":postgresql_build",
)
            """,
        )
    else:
        rel = version.replace(".", "_")
        url = "https://github.com/postgres/postgres/archive/refs/tags/REL_{version}.tar.gz".format(
            version = rel,
        )
        repository_ctx.download_and_extract(
            url = url,
            integrity = TOOL_VERSIONS[repository_ctx.attr.postgresql_version]["src"],
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
    implementation = _postgresql_repo_impl,
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
