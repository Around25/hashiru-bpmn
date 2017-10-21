# Building and Testing

This document describes how to set up your development environment to build and test hashiru-bpmn.
It also explains the basic mechanics of using git, elixir, and hex.

* [Prerequisite Software](#prerequisite-software)
* [Getting the Sources](#getting-the-sources)
* [Installing HEX Modules](#installing-hex-modules)
* [Building](#building)
* [Building Documentation Locally](#building-documentation-locally)
* [Running Tests Locally](#running-tests-locally)

See the [contribution guidelines](https://github.com/around25/hashiru-bpmn/blob/develop/CONTRIBUTING.md)
if you'd like to contribute to hashiru-bpmn.

## Prerequisite Software

Before you can build and test hashiru-bpmn, you must install and configure the
following products on your development machine:

* [Git](http://git-scm.com) and/or the **GitHub app** (for [Mac](http://mac.github.com) or
  [Windows](http://windows.github.com)); [GitHub's Guide to Installing
  Git](https://help.github.com/articles/set-up-git) is a good source of information.

* [Elixir](https://elixir-lang.org) which is used to run the code and tests, and generate distributable files.

## Getting the Sources

Fork and clone the hashiru-bpmn repository:

1. Login to your GitHub account or create one by following the instructions given
   [here](https://github.com/signup/free).
2. [Fork](http://help.github.com/forking) the [main hashiru-bpmn
   repository](https://github.com/around25/hashiru-bpmn).
3. Clone your fork of the hashiru-bpmn repository and define an `upstream` remote pointing back to
   the hashiru-bpmn repository that you forked in the first place.

```shell
# Clone your GitHub repository:
git clone git@github.com:<github username>/hashiru-bpmn.git

# Go to the hashiru-bpmn directory:
cd hashiru-bpmn

# Add the main hashiru-bpmn repository as an upstream remote to your repository:
git remote add upstream https://github.com/around25/hashiru-bpmn.git
```

## Installing HEX packages

Next, install the JavaScript modules needed to build and test gehashiru-bpmn:

```shell
# Install hashiru-bpmn project dependencies (mix.exs)
mix local.hex --force
mix local.rebar --force
mix deps.get
mix deps.compile
mix compile
```

## Building

To build hashiru-bpmn for ralease run:

```shell
mix deps.get --only prod
mix deps.compile
mix release --warnings-as-errors --env=prod
```

* Results are put in the lib folder.

## Building Documentation Locally

To generate the documentation:

```shell
# Generate all hashiru-bpmn documentation
$ mix docs
```

## Running Tests Locally

To run tests:

```shell
# Run all hashiru-bpmn tests
$ mix credo
$ mix test
```

You should execute the test suites before submitting a PR to github.

All the tests are executed on our Continuous Integration infrastructure and a PR could only be merged once the tests pass.

- Travis CI fails if any of the test suites described above fails.
