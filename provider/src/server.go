package main

import (
	"encoding/json"
	"net/http"
)

func setDefaultHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		next.ServeHTTP(w, r)
	})
}

func isOK(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(OkReponse{Message: "OK"})
}

func isKO(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusInternalServerError)
	json.NewEncoder(w).Encode(ErrorResponse{Error: "No no no no nooooohhh !"})
}


func main() {
	http.Handle("/ok", setDefaultHeaders(http.HandlerFunc(isOK)))
	http.Handle("/ko",  setDefaultHeaders(http.HandlerFunc(isKO)))
	http.ListenAndServe("localhost:3000", nil)
}
