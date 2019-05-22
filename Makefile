.DEFAULT_GOAL = help
.BROKER_CONFIG_PATH = broker-compose.yaml

blank := 
define newline

$(blank)
endef

.PHONY: help ## Display help section
help:
	@echo ""
	@echo "  Available commands:"
	@echo ""
	@grep -E '^\.PHONY: [a-zA-Z_-]+ .*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = "(: |##)"}; {printf "\033[36m\t%-25s\033[0m %s\n", $$2, $$3}'
	@echo ""

%/node_modules/: package*.json
	@cd $(@D); npm i

.ONESHELL:
provider/server: provider/src/*.go
	@echo ""; echo 🌀 Building provider server binary
	@cd $(@D); go build -o $(@F) src/*.go

.ONESHELL:
consumer/publish:
	@cd $(@D); go build $(@F).go

.PHONY: contract ## Run the consumer unit tests and create the contract
.ONESHELL:
contract: consumer/node_modules
	@echo ""; echo 🌀 Run consumer unit tests and create contract
	@cd consumer; npm test

.PHONY: contract-publish ## Publish the contract to the broker
.ONESHELL:
contract-publish: consumer/publish
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
webhook-run-recipient:
	@cd webhook-recipient && node server

.PHONY: webhook-create ## Create the webhook spec
webhook-create:
	@curl \
		-k -v \
		-d "@webhook-spec.json" \
		-H "Content-Type: application/json" \
		https://localhost:8443/webhooks

.PHONY: all ## Run all commands in the correct order
all: broker contract contract-publish verify can-i-deploy broker-stop

.PHONY: all-but-dont-stop ## Run all commands in the correct order, doesnt stop
all-but-dont-stop: broker contract contract-publish verify can-i-deploy
