# Pact playground

This project demonstrates a basic use of contract driven tests using [Pact](https://docs.pact.io/).

## Prerequisites

- OSX (sorry its just a demo)
- GNU Make +4.2.1
- nodejs
- go
- docker

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

### 1. Start broker

```shell
$ make broker
```

The broker can be accessed via http://localhost

### 2. Create Contract and publish it

The consumer has some unit tests which produce or reuse a contract when being ran:

```shell
$ make contract
```

This will produce a json file containing the contract. This contract is then published on the broker.

### 3. Verify

For this step, we use a Pact lib to run the contract request and verify that they return the expected values.

```shell
$ make verify
```

## Webhooks

To create a webhook make sure the broker is running and that a contract has been published and verified already.

Then create a webhook:

```shell
$ make webhook-create # uses the spec located in `./webhook-spec.json`
```

You can verify its existence using the HAL browser exposed by the broker.

Then you have to start the webhook recipient server in a new tab to trace the incoming request:

```shell
$ make webhook-run-recipient
```

Now you can make a modification to the contract, publish it, and see the trace in the webhook recipient terminal session.

For convenience, you can use the following command:

```shell
$ make webhook-trigger-contract-change
```

It'll cherry-pick a change, rebuild the contract, publish it, then restore the current history.

## Cleanup

Now you can stop the brocker:

```shell
$ make brocker-stop
```
