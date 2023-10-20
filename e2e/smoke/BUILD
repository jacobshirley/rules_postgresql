"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@rules_postgresql//postgresql:defs.bzl", "postgres_server_test")

postgres_server_test(
    name = "sql_query",
    cmd = "psql -U postgres -d postgres -c \"\\l\"",
)
