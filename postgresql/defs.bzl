"""Public exports"""

load("//postgresql/private:postgresql_server_test.bzl", _postgresql_server_test = "postgresql_server_test")

postgresql_server_test = _postgresql_server_test
