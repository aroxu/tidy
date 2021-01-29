package middlewares

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func VerifyRequest(data interface{}) gin.HandlerFunc {
	return func(c *gin.Context) {
		if err := c.ShouldBindJSON(data); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
			c.Abort()
			return
		}
		c.Set("body", data)
	}
}
