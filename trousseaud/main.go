// trousseaud 2020
// contact info@trousseau.io

package main

import (
	// "fmt"
	// "html"
	"log"
	// "net/http"
	"github.com/go-openapi/loads"
	"github.com/go-openapi/runtime/middleware"
	"trousseau/pkg/swagger/server/restapi"
	"trousseau/pkg/swagger/server/restapi/operations"
)

func main() {

	// Loading Swagger generate code for API
	swaggerSpec, err := loads.Analyzed(restapi.SwaggerJSON, "")
	if err != nil {
		log.Fatalln(err)
	}
	api := operations.NewTrousseaudAPI(swaggerSpec)

	// Loading server definition
	server := restapi.NewServer(api)
	defer func() {
		if err := server.Shutdown(); err != nil {
			log.Fatalln(err)
		}
	}()


	// Loading route handlers
	api.CheckHealthHandler = operations.CheckHealthHandlerFunc(Health)
	api.GetHelloUserHandler = operations.GetHelloUserHandlerFunc(GetHelloUser)

	// Define trousseaud port
	server.Port = 8080
	// Start trousseaud
	if err := server.Serve(); err != nil {
		log.Fatalln(err)
	}
}

// Health route 
func Health(operations.CheckHealthParams) middleware.Responder {
	return operations.NewCheckHealthOK().WithPayload("OK")
}

// GetHelloUser 
func GetHelloUser(user operations.GetHelloUserParams) middleware.Responder {
	return operations.NewGetHelloUserOK().WithPayload("Hello " + user.User + "!")
}
