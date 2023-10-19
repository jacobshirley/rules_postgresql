<!-- Generated with Stardoc: http://skydoc.bazel.build -->


A rule to provide a Postgres server for testing.


<a id="postgres_server_test"></a>

## postgres_server_test

<pre>
postgres_server_test(<a href="#postgres_server_test-name">name</a>, <a href="#postgres_server_test-binary">binary</a>, <a href="#postgres_server_test-cmd">cmd</a>, <a href="#postgres_server_test-data">data</a>, <a href="#postgres_server_test-env">env</a>, <a href="#postgres_server_test-fixed_args">fixed_args</a>)
</pre>

Provides runnable Postgres wrapper script and providers for a root module.

This rule waits for the Postgres server to be ready before running the script.
    

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="postgres_server_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="postgres_server_test-binary"></a>binary |  The Postgres binary to use.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |
| <a id="postgres_server_test-cmd"></a>cmd |  The command to run.   | String | optional | <code>""</code> |
| <a id="postgres_server_test-data"></a>data |  The data files to use.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="postgres_server_test-env"></a>env |  Environment variables to set for the Postgres server.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional | <code>{}</code> |
| <a id="postgres_server_test-fixed_args"></a>fixed_args |  Arguments to pass to the 'binary' (if set)   | List of strings | optional | <code>[]</code> |


