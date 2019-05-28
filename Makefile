SHELL := /bin/bash
PATH := bin:$(PATH)

.DEFAULT_GOAL := help
.BROKER_CONFIG_PATH := broker-compose.yaml

.PHONY: help ## Display help section
help:
	@echo ""
	@echo "  Available commands:"
	@echo ""
	@grep -E '^\.PHONY: [a-zA-Z_-]+ .*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = "(: |##)"}; {printf "\033[36m\t%-32s\033[0m %s\n", $$2, $$3}'
	@echo ""

%/node_modules/:
	@echo ""; echo 🌀 Install npm dependencies
	@cd $(@D); npm i

.ONESHELL:
provider/server: provider/src/*.go
	@echo ""; echo 🌀 Building provider server binary
	@cd $(@D); go build -o $(@F) src/*.go

.ONESHELL:
consumer/publish:
	@echo ""; echo 🌀 Building consumer publish command binary
	@cd $(@D); go build $(@F).go

.PHONY: contract ## Run the consumer unit tests, creates the contract, publish it
.ONESHELL:
contract: consumer/node_modules consumer/publish
	@echo ""; echo 🌀 Run consumer unit tests and create contract
	@cd consumer; npm test
	@echo ""; echo 🌀 Publish contract
	@cd consumer; ./publish

.PHONY: broker ## Start the brocker
broker:
	@echo ""; echo 🌀 Start broker
	@docker-compose -f $(.BROKER_CONFIG_PATH) up -d

.PHONY: broker-stop ## Stop the brocker
broker-stop:
	@echo ""; echo 🌀 Stop broker
	@docker-compose -f $(.BROKER_CONFIG_PATH) down

.PHONY: provider-start
.ONESHELL:
provider-start: provider/server
	@cd provider; ./server & echo $$! > ./server.pid
	@echo ""; echo 🌀 Provider server started

.PHONY: provider-stop
.ONESHELL:
provider-stop:
	@cd provider; kill -s TERM $$(cat "./server.pid"); rm ./server.pid
	@echo ""; echo 🌀 Provider server stopped

.PHONY: verify ## Start the provider and test the contract against it
verify: provider-start
	@echo ""; echo 🌀 Test the Consumer contract against the Provider **and** publishes the results
	@go test -v -run TestProvider ./provider/tests;
	make provider-stop

.PHONY: verify-w-docker ## Same as verify, using standalone dockerised cli (though it doesn't publish results)
verify-w-docker: provider-start
	docker run \
		--rm \
		-it \
		pactfoundation/pact-ref-verifier \
			--broker-url http://host.docker.internal/\
			--hostname host.docker.internal \
			--port 3000 \
			--provider-name MyProvider

.PACTICIPANTS = MyProvider MyConsumer
.PHONY: can-i-deploy ## Checks if all "pacticipants are compliant"
can-i-deploy:
	@echo ""; echo 🌀 Checks if all \"pacticipants\" are compliant
	@for pacticipant in $(.PACTICIPANTS); do \
		echo can i deploy $$pacticipant ?; \
		echo ----------------------------; \
		pact-broker can-i-deploy -a $$pacticipant -b http://localhost -l; \
		echo ""; \
	done;

.PHONY: webhook-run-recipient ## Run the webhook logger
webhook-run-recipient: webhook-recipient/node_modules
	@cd webhook-recipient && node server

.PHONY: webhook-create ## Create the webhook spec
webhook-create:
	@create-webhook

.PHONY: webhook-delete-all ## Deletes all webhooks
webhook-delete-all:
	@delete-webhooks

.PHONY: webhook-trigger-contract-change ## Trigger contract change (cherry-picks a change)
webhook-trigger-contract-change:
	@echo ""; echo 🌀 Cherry picking commit 6e17876
	@git stash
	@git cherry-pick 6e17876
	$(MAKE) contract
	@echo ""; echo 🌀 Restoring commit history to HEAD
	@git reset --hard HEAD~1
	@git stash apply
	$(MAKE) contract

.PHONY: cleanup ## Cleanup task
cleanup:
	@rm -f .webhooks
	@$(MAKE) broker-stop

.PHONY: all ## Run all commands in the correct order
all: broker contract verify can-i-deploy
	@echo 🌀 Done
	@echo A pact between a consumer and a provider is now published and verified on the broker: http://localhost
	@echo Use "make broker-stop" to stop the broker.
	@echo
