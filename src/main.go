package main

import (
	"fmt"
	"time"

	"github.com/gin-gonic/gin"
)

func getMessage(c *gin.Context) {
	c.JSON(200, gin.H{
		"message":   "Automate all the things!",
		"timestamp": time.Now().Format(time.RFC1123),
	})
}

func main() {
	router := gin.Default()
	router.GET("/msg", getMessage)

	fmt.Println("Server is running at port 8080")
	router.Run()

}
