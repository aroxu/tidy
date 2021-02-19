package middlewares

import (
	"net/http"

	"github.com/aroxu/tidy-engine/config"
	"github.com/aroxu/tidy-engine/utils"
	"github.com/dgrijalva/jwt-go"
	"github.com/gin-contrib/sessions"
	"github.com/gin-gonic/gin"
)

func Auth() gin.HandlerFunc {
	return func(c *gin.Context) {
		if !config.Config.EnableAuth {
			c.Set("isAuth", true)
			c.Set("user", config.GuestUser)
			c.Next()
			return
		}
		session := sessions.Default(c)

		Itoken := session.Get("token")
		token, ok := Itoken.(string)
		if !ok {
			c.Set("isAuth", false)
			c.Next()
			return
		}

		claims := &utils.JWTClaims{}
		_, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
			return []byte(config.Config.JwtSecret), nil
		})

		if err != nil {
			c.Set("isAuth", false)
			c.Next()
			return
		}

		user := config.LoadUser(claims.UserName)
		c.Set("user", user)
		c.Set("isAuth", true)
		c.Next()
	}
}

func UserRole() gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole := []string{"guest"}
		user, exists := c.Get("user")
		if exists {
			userRole = append(userRole, user.(*config.UserStruct).Role...)
		}
		c.Set("userRole", userRole)
	}
}

func FolderUserPermission() gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.Param("id")
		userRole := c.MustGet("userRole").([]string)
		folder := config.LoadFolder(id)
		if folder == nil {
			c.HTML(http.StatusNotFound, "404.html", gin.H{})
			c.Abort()
			return
		}

		if hasPermission := config.CheckPermission(&userRole, &folder.AccessRole); !hasPermission {
			c.HTML(http.StatusNotFound, "404.html", gin.H{})
			c.Abort()
			return
		}
		c.Set("folder", folder)
		c.Next()
	}
}

func NotAuthOnly() gin.HandlerFunc {
	return func(c *gin.Context) {
		if !config.Config.EnableAuth {
			c.Redirect(302, "/app")
			c.Abort()
			return
		}
		session := sessions.Default(c)
		token := session.Get("token")

		if str, ok := token.(string); ok || str != "" {
			claims := &utils.JWTClaims{}
			_, err := jwt.ParseWithClaims(str, claims, func(token *jwt.Token) (interface{}, error) {
				return []byte(config.Config.JwtSecret), nil
			})

			if err != nil {
				c.Set("isAuth", false)
			} else {
				c.Redirect(302, "/app")
				c.Abort()
			}
			return
		}

		c.Set("isAuth", false)
		c.Next()
	}
}
