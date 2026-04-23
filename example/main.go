package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/TykTechnologies/go-mdcb"
)

func main() {
	log.Println("calling endpoints")

	cfg := mdcb.NewConfiguration()
	cfg.Servers = mdcb.ServerConfigurations{
		{
			URL:         "http://localhost:8181",
			Description: "",
			Variables:   nil,
		},
	}

	cfg.HTTPClient = &http.Client{
		Timeout: time.Second * 45,
	}

	client := mdcb.NewAPIClient(cfg)

	// Call health endpoint.
	health, raw, err := client.DefaultAPI.HealthGet(context.Background()).Execute()
	if err != nil {
		log.Println("raw health response on error", raw)
		log.Fatalln("error getting health: %w", err)
	}

	log.Println("health response:", health)

	// Call data planes endpoints.
	req := client.DefaultAPI.DataplanesGet(context.Background()).
		XTykAuthorization("secret")

	nodes, raw, err := req.Execute()
	if err != nil {
		log.Println("raw data planes response on error", raw)
		log.Fatalln("error fetching data plane nodes:", err)
	}

	fmt.Println("nodes:", nodes)
}
