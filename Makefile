.DEFAULT_GOAL = help
.BROCKER_PATH = pact-scripts/brocker-compose.yaml

.PHONY: help ## Display help section
help:
	@echo ""
	@echo "  Available commands:"
	@echo ""
	@grep -E '^\.PHONY: [a-zA-Z_-]+ .*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = "(: |##)"}; {printf "\033[36m\t%-25s\033[0m %s\n", $$2, $$3}'
	@echo ""

%/node_modules/: package*.json
	@cd $(@D); npm i

.GO_BIN := provider/server pact-scripts/publish

.ONESHELL:
$(.GO_BIN):
	@cd $(@D); go build $(@F).go

.PHONY: contract ## Run the consumer unit tests and create the contract
.ONESHELL:
contract: consumer/node_modules
	@cd consumer; npm test

.PHONY: contract-publish ## Publish the contract to the broker
.ONESHELL:
contract-publish: pact-scripts/publish
	@cd pact-scripts; ./publish

.PHONY: broker ## Start the brocker
broker:
	@docker-compose -f $(.BROCKER_PATH) up -d

.PHONY: broker-stop ## Stop the brocker
broker-stop:
	@docker-compose -f $(.BROCKER_PATH) down

.PHONY: provider-start
.ONESHELL:
provider-start: pact-scripts/node_modules provider/server
	@cd provider; ./server & echo $$! > ./server.pid

.PHONY: provider-stop
.ONESHELL:
provider-stop: 
	@cd provider; kill -9 $$(cat "./server.pid"); rm ./server.pid

.PHONY: verify ## Start the provider and test the contract against it
.ONESHELL:
verify: pact-scripts/node_modules provider-start
	@cd pact-scripts; ./node_modules/.bin/jest __verify__/ --runInBand; cd ..
	make provider-stop
