.DEFAULT_GOAL = help
.BROCKER_CONFIG_PATH = brocker-compose.yaml

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
	@echo 🌀 Building provider server binary
	@cd $(@D); go build -o $(@F) src/*.go

.ONESHELL:
consumer/publish:
	@cd $(@D); go build $(@F).go

.PHONY: contract ## Run the consumer unit tests and create the contract
.ONESHELL:
contract: consumer/node_modules
	@echo 🌀 Run consumer unit tests and create contract
	@cd consumer; npm test

.PHONY: contract-publish ## Publish the contract to the broker
.ONESHELL:
contract-publish: consumer/publish
	@echo 🌀 Publish contract
	@cd consumer; ./publish

.PHONY: broker ## Start the brocker
broker:
	@echo 🌀 Start broker
	@docker-compose -f $(.BROCKER_CONFIG_PATH) up -d

.PHONY: broker-stop ## Stop the brocker
broker-stop:
	@echo 🌀 Stop broker
	@docker-compose -f $(.BROCKER_CONFIG_PATH) down

.PHONY: provider-start
.ONESHELL:
provider-start: provider/server
	@cd provider; ./server & echo $$! > ./server.pid
	@echo 🌀 Provider server started

.PHONY: provider-stop
.ONESHELL:
provider-stop:
	@cd provider; kill -s TERM $$(cat "./server.pid"); rm ./server.pid
	@echo 🌀 Provider server stopped

.PHONY: verify ## Start the provider and test the contract against it
verify: provider-start
	@echo 🌀 Start the provider and test the contract against it
	@go test -v -run TestProvider ./provider/tests;
	make provider-stop

.PHONY: verify-w-docker ## Same as verify, using standalone dockerised cli
verify-w-docker: provider-start
	@echo 🌀 Start the provider and test the contract against it
	docker run \
		--rm \
		-it \
		pactfoundation/pact-ref-verifier \
			--broker-url http://host.docker.internal/\
			--hostname host.docker.internal \
			--port 3000 \
			--provider-name MyProvider
	make provider-stop

.PHONY: all ## Run all commands in the correct order
all: broker contract contract-publish verify-w-docker broker-stop
