package main

import (
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func SetUpRouter() *gin.Engine {
	router := gin.Default()
	return router
}

func TestMsg(t *testing.T) {
	mockResponse := `"message":"Automate all the things!"`
	r := SetUpRouter()
	r.GET("/msg", getMessage)
	req, _ := http.NewRequest("GET", "/msg", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	responseData, _ := io.ReadAll(w.Body)
	assert.Contains(t, string(responseData), mockResponse)
	assert.Equal(t, http.StatusOK, w.Code)
}
