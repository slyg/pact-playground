package main

import (
	"encoding/json"
	"net/http"
)

func isOK(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(OkReponse{Message: "OK"})
}

func isNotOK(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusInternalServerError)
	json.NewEncoder(w).Encode(ErrorResponse{Error: "No no no no nooooohhh !"})
}
