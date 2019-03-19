package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"

	"github.com/pact-foundation/pact-go/dsl"
	"github.com/pact-foundation/pact-go/types"
)

func main () {

	revision, err := exec.Command(`git`, []string{"rev-parse", "HEAD"}...).Output();

	if err != nil {
		log.Println("ERROR: ", err)
		os.Exit(1)
	}
	fmt.Printf("%s\n", revision)

	p := dsl.Publisher{}
	nerr := p.Publish(types.PublishRequest{
		PactURLs: []string{"../consumer/pacts/myconsumer-myprovider.json"},
		PactBroker:	"http://localhost",
		ConsumerVersion: string(revision),
		Tags: []string{"master"},
	})

	if nerr != nil {
		log.Println("ERROR: ", err)
		os.Exit(1)
	}

}