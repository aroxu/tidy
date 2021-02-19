package routes

import (
	c "github.com/aroxu/tidy-engine/controllers"
	m "github.com/aroxu/tidy-engine/middlewares"
	"github.com/gin-gonic/gin"
)

func InitRoutes(r *gin.RouterGroup) {
	r.GET("/", m.NotAuthOnly(), c.SignInPage)
	r.POST("/signin", m.NotAuthOnly(), m.VerifyRequest(&c.SignInReq{}), c.SignIn)

	r.GET("/app", m.Auth(), m.UserRole(), c.App)
	r.GET("/app/:id", m.Auth(), m.UserRole(), m.FolderUserPermission(), c.FileList)
	r.GET("/app/:id/download", m.Auth(), m.UserRole(), m.FolderUserPermission(), c.Download)
	r.GET("/app/:id/download/folder", m.Auth(), m.UserRole(), c.DownloadFolder)
	r.GET("/app/:id/folder", m.Auth(), m.UserRole(), m.FolderUserPermission(), c.DownloadFolderReady)
	r.POST("/signout", m.Auth(), c.SignOut)
}
