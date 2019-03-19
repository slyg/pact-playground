package main

import (
	"encoding/json"
	"net/http"
)

type OkReponse struct { Message string `json:"message"` }
type ErrorResponse struct { Error string `json:"error"` } 

func main() {
	http.HandleFunc("/ok", func (w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		json.NewEncoder(w).Encode(OkReponse{Message: "OK"})
	})

	http.HandleFunc("/ko", func (w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(ErrorResponse{Error: "No no no no nooooohhh !"})
	})

	http.ListenAndServe("localhost:3000", nil)

}