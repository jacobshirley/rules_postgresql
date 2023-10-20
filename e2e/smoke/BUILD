"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@rules_postgresql//postgresql:defs.bzl", "postgresql_server_test")

postgresql_server_test(
    name = "sql_query",
    cmd = "psql -d postgres -c \"\\l\"",
)
