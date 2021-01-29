package middlewares

import (
	"fmt"
	"net/http"

	"github.com/aroxu/tidy-engine/config"
	"github.com/aroxu/tidy-engine/utils"
	"github.com/dgrijalva/jwt-go"
	"github.com/gin-contrib/sessions"
	"github.com/gin-gonic/gin"
)

func Auth(useRedirect bool) gin.HandlerFunc {
	return func(c *gin.Context) {
		session := sessions.Default(c)
		token := session.Get("token").(string)

		notValid := func(err error) {
			session.Delete("token")
			session.Save()
			if useRedirect {
				c.Redirect(302, "/app")
			} else {
				c.JSON(http.StatusUnauthorized, err.Error())
			}
			c.Abort()
		}

		claims := &utils.JWTClaims{}
		_, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
			return []byte(config.Config.JwtSecret), nil
		})

		if err != nil {
			notValid(err)
			return
		}

		user := config.LoadUser(claims.UserName)
		c.Set("user", user)
		c.Next()
	}
}

func NotAuthOnly() gin.HandlerFunc {
	return func(c *gin.Context) {
		session := sessions.Default(c)
		token := session.Get("token")
		fmt.Println(token)

		if str, ok := token.(string); ok || str != "" {
			c.Redirect(302, "/app")
			c.Abort()
			return
		}

		c.Next()
	}
}
