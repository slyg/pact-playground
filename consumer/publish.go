package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/pact-foundation/pact-go/dsl"
	"github.com/pact-foundation/pact-go/types"
)

// PackageJSON is package.json struct
type PackageJSON struct {
	Version string `json:"version"`
}

func main() {

	revision := getRevision()
	version := getPackageVersion()
	consumerVersion := strings.TrimSpace(version + "-" + revision)
	p := dsl.Publisher{}

	err := p.Publish(types.PublishRequest{
		PactURLs:        []string{"../consumer/pacts/pactconsumer_frontend-pactprovider_backend.json"},
		PactBroker:      "http://localhost:80",
		ConsumerVersion: consumerVersion,
		Tags:            []string{"master"},
	})

	if err != nil {
		log.Println("ERROR: ", err)
		os.Exit(1)
	}

}

func getRevision() string {
	revision, err := exec.Command(`git`, []string{"rev-parse", "HEAD"}...).Output()

	if err != nil {
		log.Println("ERROR: ", err)
		os.Exit(1)
	}
	fmt.Printf("%s\n", revision)

	return string(revision)
}

func getPackageVersion() string {
	jsonFile, err := os.Open("package.json")
	if err != nil {
		fmt.Println(err)
	}
	defer jsonFile.Close()
	byteValue, _ := ioutil.ReadAll(jsonFile)

	var pkg PackageJSON
	json.Unmarshal(byteValue, &pkg)

	return pkg.Version
}
