package controllers

import (
	"net/http"

	"github.com/aroxu/tidy-engine/config"
	"github.com/aroxu/tidy-engine/utils"
	"github.com/gin-contrib/sessions"
	"github.com/gin-gonic/gin"
)

func SignInPage(c *gin.Context) {
	c.HTML(http.StatusOK, "signin.html", gin.H{})
}

type SignInReq struct {
	Name     string `json:"name" form:"name" binding:"required"`
	Password string `json:"password" form:"password" binding:"required"`
}

func SignIn(c *gin.Context) {
	body := c.MustGet("body").(*SignInReq)
	session := sessions.Default(c)

	user := config.LoadUser(body.Name)
	if user == nil {
		c.JSON(http.StatusUnauthorized, gin.H{})
		return
	}
	if isCorrect := utils.CheckPassword(body.Password, user.Password); !isCorrect {
		c.JSON(http.StatusUnauthorized, gin.H{})
		return
	}

	token, err := utils.CreateJwtToken(user.Name)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{})
		return
	}

	session.Set("token", token)
	session.Save()
	c.JSON(http.StatusOK, gin.H{})
}

func SignOut(c *gin.Context) {
	session := sessions.Default(c)
	session.Delete("token")
	session.Save()
	c.JSON(http.StatusOK, gin.H{})
}

func App(c *gin.Context) {
	folderList := config.FolderList
	c.HTML(http.StatusOK, "main.html", gin.H{
		"folder": folderList,
	})
}

func FileList(c *gin.Context) {
}

func Download(c *gin.Context) {
}
