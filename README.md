# Pact playground

This project demonstrates a basic use of contract driven tests using [Pact](https://docs.pact.io/).

## Prerequisites

You may want to use GNU Make 4.2.1 to run the commands, have nodejs installed and a docker daemon running.

## Comments

This repo consists of 2 simple applications:

- a consumer, pulling data
- a provider, serving data

The goal is to make sure that the provider can always serve the consumer with expected data in an async manner.

Use the following command to list the available tasks:

```shell
$ make
# or
$ make help
```

## Scenario

### 1. Contract

The consumer has some unit tests which produce or reuse a contract when being ran:

```shell
$ make contract
```

This will produce a json file containing the contract.

### 2. Publish

This contract can them be published on a brocker:

```shell
$ make broker
$ make contract-publish
```

### 3. Verify

For this step, we use a Pact lib to run the contract request and verify that they return the expected values.

```shell
$ make verify
```

Now you can stop the brocker:

```shell
$ make brocker-stop
```
