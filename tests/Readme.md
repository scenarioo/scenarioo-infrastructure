# Tests

These are for testing the `./infra.sh` and it's commands. We are using [bats](https://github.com/sstephenson/bats) as a testing framework.
Our test files look something like this:

```
#!/usr/bin/env bats

load environment        # see environment.bash
setup() {
    setup_environment   # defined in environment.bash
}

@test "infra.sh - it should print available commands" {
  result="$(./infra.sh)"
  expected="$(cat tests/expected/infra_showCommands.out)"

  diff <(echo "$result") <(echo "$expected")
}

teardown() {
    restore_environment # defined in environment.bash
}
```

Any exit code other than `0` will lead to a failing test. Expected outputs are stored in the `expected` directory.

## Running tests

Install [bats](https://github.com/sstephenson/bats) or [bats-core](https://github.com/bats-core/bats-core) and then execute `bats tests/` in the project root.
We don't use the `config.json` in the project root but instead `tests/config.test.json`. This is configured in the `setup_environment` method of the `environment.bash`helper script.

## Mocking commands

We are currently mocking curl and it's responses, see the `bin` and `fixtures` directory. Inspired by [https://pbrisbin.com/posts/mocking_bash/](https://pbrisbin.com/posts/mocking_bash/)

The initial call to `curl` will go through. The response and exit code will then be stored under `fixtures`. 
Future calls with the same arguments will be mocked from the previous recorded response in `fixtures`.
This speeds up our tests and makes us independent of CircleCI being up and our artifacts still being available.

You can checkout which calls were served from fixtures and which weren't by looking at `tmp/invocation.log`.