%/node_modules/: package*.json
	@cd $(@D); npm i

.PHONY: create-contract
.ONESHELL:
contract: consumer/node_modules
	@cd consumer; npm test

.PHONY: contract-publish
.ONESHELL:
contract-publish: pact-scripts/node_modules
	@cd pact-scripts; node publish

.PHONY: broker-start
broker-start:
	@docker-compose -f pact-scripts/brocker-compose.yaml up -d

.PHONY: broker-stop
broker-stop:
	@docker-compose -f pact-scripts/brocker-compose.yaml down

.PHONY: provider-start
.ONESHELL:
provider-start: pact-scripts/node_modules
	@cd provider; node server & echo $$! > ./server.pid

.PHONY: provider-stop
.ONESHELL:
provider-stop: 
	@cd provider; kill -9 $$(cat "./server.pid"); rm ./server.pid

.PHONY: verify
.ONESHELL:
verify: pact-scripts/node_modules provider-start
	@cd pact-scripts; ./node_modules/.bin/jest __verify__/ --runInBand; cd ..
	make provider-stop
