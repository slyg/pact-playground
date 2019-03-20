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
provider/server:
	@cd $(@D); go build -o $(@F) src/*.go

.ONESHELL:
consumer/publish:
	@cd $(@D); go build $(@F).go

.PHONY: contract ## Run the consumer unit tests and create the contract
.ONESHELL:
contract: consumer/node_modules
	@echo Run consumer unit tests and create contract
	@cd consumer; npm test

.PHONY: contract-publish ## Publish the contract to the broker
.ONESHELL:
contract-publish: consumer/publish
	@echo Publish contract
	@cd consumer; ./publish

.PHONY: broker ## Start the brocker
broker:
	@echo Start broker
	@docker-compose -f $(.BROCKER_CONFIG_PATH) up -d

.PHONY: broker-stop ## Stop the brocker
broker-stop:
	@echo Stop broker
	@docker-compose -f $(.BROCKER_CONFIG_PATH) down

.PHONY: provider-start
.ONESHELL:
provider-start: provider/server
	@echo Start provider server
	@cd provider; ./server & echo $$! > ./server.pid

.PHONY: provider-stop
.ONESHELL:
provider-stop:
	@echo Stop provider server
	@cd provider; kill -9 $$(cat "./server.pid"); rm ./server.pid

.PHONY: verify ## Start the provider and test the contract against it
.ONESHELL:
verify: provider-start
	@echo Start the provider and test the contract against it
	@cd provider; go test -v -run TestProvider; cd ..
	make provider-stop

.PHONY: all ## Run all commands in the correct order
all: broker contract contract-publish verify broker-stop
