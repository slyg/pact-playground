package main

import (
	"testing"

	"github.com/pact-foundation/pact-go/dsl"
	"github.com/pact-foundation/pact-go/types"
	"os/exec"
	"log"
)

func TestProvider(t *testing.T) {

	pact := &dsl.Pact{
		Consumer:                 "MyConsumer",
		Provider:                 "MyProvider",
		DisableToolValidityCheck: true,
	}

	cmd := exec.Command("git", "rev-parse", "--short", "HEAD")
	out, err := cmd.CombinedOutput()
	if err != nil {
        log.Fatalf("cmd.Run() failed with %s\n", err)
    }

	pact.VerifyProvider(t, types.VerifyRequest{
		// BrokerURL:       "http://localhost",
		// Tags:            []string{"master"},
		PactURLs:                   []string{"http://localhost/pacts/provider/MyProvider/consumer/MyConsumer/latest"},
		ProviderBaseURL:            "http://localhost:3000",
		PublishVerificationResults: true,
		ProviderVersion:            string(out),
		StateHandlers: types.StateHandlers{
			"default": func() error { return nil },
		},
	})

}
