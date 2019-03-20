package main

import (
	"net/http"
)

func main() {
	http.Handle("/ok", setDefaultHeaders(http.HandlerFunc(isOK)))
	http.Handle("/ko",  setDefaultHeaders(http.HandlerFunc(isNotOK)))
	http.ListenAndServe("localhost:3000", nil)
}
