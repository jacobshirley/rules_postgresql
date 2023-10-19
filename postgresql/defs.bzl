"""Public exports"""

load("//postgresql/private:postgres_server_test.bzl", _postgres_server_test = "postgres_server_test")

postgres_server_test = _postgres_server_test
