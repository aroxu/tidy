package controllers

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"path"
	"path/filepath"
	"strconv"
	"strings"
	"time"

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
	_, exits := c.Get("user")
	if !exits {
		c.JSON(http.StatusUnauthorized, gin.H{})
	}
	session := sessions.Default(c)
	session.Delete("token")
	session.Save()
	c.JSON(http.StatusOK, gin.H{})
}

func App(c *gin.Context) {
	userRole := c.MustGet("userRole").([]string)
	isAuth := c.MustGet("isAuth").(bool)
	accessAbleFolderList := map[string]*config.FolderStruct{}
	for _, d := range config.FolderList {
		if hasPermission := config.CheckPermission(&userRole, &d.AccessRole); hasPermission {
			accessAbleFolderList[d.Name] = d
		}
	}

	formated := []*config.FolderStruct{}
	for _, v := range accessAbleFolderList {
		formated = append(formated, v)
	}

	c.HTML(http.StatusOK, "main.html", gin.H{
		"isAuth": isAuth,
		"folder": formated,
	})
}

func FileList(c *gin.Context) {
	id := c.Param("id")
	query, err := url.QueryUnescape(c.Query("path"))
	if err != nil {
		c.HTML(http.StatusNotFound, "404.html", gin.H{})
		return
	}
	folder := c.MustGet("folder").(*config.FolderStruct)

	if fi := utils.PathCheck(folder.Path, query); fi == nil || !fi.Mode().IsDir() {
		c.HTML(http.StatusNotFound, "404.html", gin.H{})
		return
	}

	dirInfo, err := ioutil.ReadDir(path.Join(folder.Path, query))
	if err != nil {
		c.HTML(http.StatusInternalServerError, "404.html", gin.H{})
		return
	}

	info := []map[string]interface{}{}
	for _, d := range dirInfo {
		if d.Name() == "__macosx" || d.Name() == ".DS_Store" || d.Name() == ".localized" || strings.HasPrefix(d.Name(), "._.") {
			continue
		}
		info = append(info, map[string]interface{}{
			"name":  d.Name(),
			"isDir": d.IsDir(),
			"size":  utils.ByteFormat(d.Size()),
		})
	}

	c.HTML(http.StatusOK, "main-list.html", gin.H{
		"id":      id,
		"curPath": query,
		"info":    info,
		"isAuth":  c.MustGet("isAuth").(bool),
	})
}

func Download(c *gin.Context) {
	query, err := url.QueryUnescape(c.Query("path"))
	if err != nil {
		c.HTML(http.StatusNotFound, "404.html", gin.H{})
		return
	}
	folder := c.MustGet("folder").(*config.FolderStruct)

	fi := utils.PathCheck(folder.Path, query)
	if fi == nil {
		c.HTML(http.StatusNotFound, "404.html", gin.H{})
		return
	}

	target := path.Join(folder.Path, query)
	if fi.Mode().IsDir() {
		fileName := strconv.Itoa(int(time.Now().Unix())) + utils.CreateRandomString(5) + ".zip"
		if err := utils.ZipFolder(target, path.Join(config.GetConfigDir(), "temp", fileName)); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{})
		} else {
			c.JSON(http.StatusOK, gin.H{
				"file": fileName,
			})
		}
		return
	}

	filename := filepath.Base(path.Join(folder.Path, query))
	c.Writer.Header().Add("Content-Disposition", fmt.Sprintf("attachment; filename=%s", filename))
	c.Writer.Header().Add("Content-Type", "application/octet-stream")

	c.File(target)
}

func DownloadFolderReady(c *gin.Context) {
	id := c.Param("id")
	folder := c.MustGet("folder").(*config.FolderStruct)

	query, err := url.QueryUnescape(c.Query("path"))
	if err != nil {
		c.HTML(http.StatusNotFound, "404.html", gin.H{})
		return
	}

	fi := utils.PathCheck(folder.Path, query)
	if fi == nil {
		c.HTML(http.StatusNotFound, "404.html", gin.H{})
		return
	}

	if !fi.Mode().IsDir() {
		c.HTML(http.StatusNotFound, "404.html", gin.H{})
		return
	}

	c.HTML(http.StatusOK, "main-folder.html", gin.H{
		"isAuth": c.MustGet("isAuth").(bool),
		"path":   query,
		"id":     id,
	})
}

func DownloadFolder(c *gin.Context) {
	query, err := url.QueryUnescape(c.Query("path"))
	if err != nil || len(query) < 10 {
		c.HTML(http.StatusNotFound, "404.html", gin.H{})
		return
	}
	filename := c.Query("filename")

	filePath := path.Join(config.GetConfigDir(), "temp", query)
	if fi, err := os.Stat(filePath); err != nil || !fi.Mode().IsRegular() {
		c.HTML(http.StatusNotFound, "404.html", gin.H{})
		return
	}

	c.Writer.Header().Add("Content-Disposition", fmt.Sprintf("attachment; filename=%s", filename))
	c.Writer.Header().Add("Content-Type", "application/octet-stream")

	c.File(filePath)
}
