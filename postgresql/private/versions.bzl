"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "15.3": "sha384-JCfvuaHC/j7GB2trCGCQ6slFoSz1gfLXmfIBZat97l84MQl7UlBG9dNkUJlzJAFJ",
}
