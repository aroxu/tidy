package main

import (
	"html/template"
	"log"
	"math/rand"
	"net/url"
	"path"
	"path/filepath"
	"strconv"
	"time"

	"github.com/aroxu/tidy-engine/config"
	"github.com/aroxu/tidy-engine/routes"
	"github.com/gin-contrib/sessions"
	"github.com/gin-contrib/sessions/cookie"
	"github.com/gin-gonic/gin"
)

func startServer() {
	templateAdd := func(a, b int) (int, error) {
		return a + b, nil
	}
	templateCurYear := func() (string, error) {
		return time.Now().Format("2006"), nil
	}
	templateServiceName := func() (string, error) {
		return config.Config.Name, nil
	}
	templateQueryEscape := func(str string) (string, error) {
		return url.QueryEscape(str), nil
	}
	templatePathJoin := func(str1, str2 string) (string, error) {
		return path.Join(str1, str2), nil
	}
	templatePathBase := func(path string) (string, error) {
		return filepath.Base(path), nil
	}
	templateIsAuthEnable := func() (bool, error) {
		return config.Config.EnableAuth, nil
	}

	r := gin.Default()
	funcMap := template.FuncMap{
		"add":          templateAdd,
		"curYear":      templateCurYear,
		"serviceName":  templateServiceName,
		"queryEscape":  templateQueryEscape,
		"pathJoin":     templatePathJoin,
		"pathBase":     templatePathBase,
		"isAuthEnable": templateIsAuthEnable,
	}
	r.SetFuncMap(funcMap)
	r.LoadHTMLGlob("templates/*/*.html")
	store := cookie.NewStore([]byte("secret"))
	r.Use(sessions.Sessions("mysession", store))
	routes.InitRoutes(r.Group(""))
	r.Run(":" + strconv.Itoa(int(config.Config.Port)))

}

func main() {
	rand.Seed(time.Now().Unix())
	if err := config.Load("./data/"); err != nil {
		log.Fatal(err)
	}
	startServer()

	return
}
