package main

// OkReponse represents an ok response
type OkReponse struct {
	Message string `json:"message"`
}

// ErrorResponse represents a not ok response
type ErrorResponse struct {
	Error string `json:"error"`
}
