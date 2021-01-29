package routes

import (
	c "github.com/aroxu/tidy-engine/controllers"
	m "github.com/aroxu/tidy-engine/middlewares"
	"github.com/gin-gonic/gin"
)

func InitRoutes(r *gin.RouterGroup) {
	r.GET("/", m.NotAuthOnly(), c.SignInPage)
	r.POST("/signin", m.NotAuthOnly(), m.VerifyRequest(&c.SignInReq{}), c.SignIn)

	r.GET("/app", m.Auth(true), c.App)
}
