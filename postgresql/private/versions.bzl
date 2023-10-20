"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "15.3": {
        "bin": {
            "aarch64-apple-darwin": "sha384-c2JXifZBYr2Ycj0KTyA/tL2WeJrJc04PVeibkcRD79DM/iHyWymZEQH3sN3+kLRS",
            "x86_64-apple-darwin": "sha384-c2JXifZBYr2Ycj0KTyA/tL2WeJrJc04PVeibkcRD79DM/iHyWymZEQH3sN3+kLRS",
            "x86_64-pc-windows-msvc": "sha384-t8ZtT/NzGkZAtxPRcRk1Jyc97g23BgRnHoPWJTpXKH06JhDRnnrSeP+7x0zE95r2",
        },
        "src": "sha384-JCfvuaHC/j7GB2trCGCQ6slFoSz1gfLXmfIBZat97l84MQl7UlBG9dNkUJlzJAFJ",
    },
}
