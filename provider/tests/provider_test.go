package main

import (
	"testing"

	"github.com/pact-foundation/pact-go/dsl"
	"github.com/pact-foundation/pact-go/types"
)


func TestProvider(t *testing.T) {

	pact := &dsl.Pact{
		Consumer: "MyConsumer",
		Provider: "MyProvider",
		DisableToolValidityCheck: true,
	}

	pact.VerifyProvider(t, types.VerifyRequest{
		ProviderBaseURL: "http://localhost:3000",
		BrokerURL: "http://localhost",
		StateHandlers: types.StateHandlers{
			"default": func() error { return nil },
		},
	})

}