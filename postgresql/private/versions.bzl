"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "15.3": {
        "src": "sha384-JCfvuaHC/j7GB2trCGCQ6slFoSz1gfLXmfIBZat97l84MQl7UlBG9dNkUJlzJAFJ",
        "bin": {
            "x86_64-pc-windows-msvc": "sha384-t8ZtT/NzGkZAtxPRcRk1Jyc97g23BgRnHoPWJTpXKH06JhDRnnrSeP+7x0zE95r2",
        },
    },
}
