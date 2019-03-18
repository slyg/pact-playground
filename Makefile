%/node_modules/:
	@cd $(@D); npm i

.PHONY: create-contract
.ONESHELL:
contract: consumer/node_modules
	@cd consumer; npm test

.PHONY: start-broker
start-broker:
	@docker-compose -f pact-scripts/brocker-compose.yaml up -d

.PHONY: stop-broker
stop-broker:
	@docker-compose -f pact-scripts/brocker-compose.yaml down

.PHONY: publish-contract
.ONESHELL:
publish-contract: pact-scripts/node_modules
	@cd pact-scripts; node publish
