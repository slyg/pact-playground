package main

import (
	"testing"

	"github.com/pact-foundation/pact-go/dsl"
	"github.com/pact-foundation/pact-go/types"
)

func TestProvider(t *testing.T) {

	pact := &dsl.Pact{
		Consumer:                 "MyConsumer",
		Provider:                 "MyProvider",
		DisableToolValidityCheck: true,
	}

	pact.VerifyProvider(t, types.VerifyRequest{
		// BrokerURL:       "http://localhost",
		// Tags:            []string{"master"},
		PactURLs:        []string{"http://localhost/pacts/provider/MyProvider/consumer/MyConsumer/latest"},
		ProviderBaseURL: "http://localhost:3000",
		StateHandlers: types.StateHandlers{
			"default": func() error { return nil },
		},
	})

}
