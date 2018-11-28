package main

import (
	"log"
	"math/rand"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.New()
	router.Use(gin.Recovery())

	// Allow cors
	corsConfig := cors.DefaultConfig()
	corsConfig.AllowAllOrigins = true
	corsConfig.AddAllowHeaders("Authorization", "*")
	router.Use(cors.New(corsConfig))

	// Public routes
	router.POST("/probability", func(c *gin.Context) {
		randNumber := rand.Float64()

		c.JSON(200, gin.H{
			"probability": randNumber,
		})
	})

	log.Println("backend is running")
	router.Run()
}
