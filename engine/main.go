package main

import (
	"fmt"
	"html/template"
	"log"
	"math/rand"
	"net/url"
	"os"
	"path"
	"path/filepath"
	"runtime"
	"strconv"
	"time"

	"github.com/aroxu/tidy-engine/config"
	"github.com/aroxu/tidy-engine/routes"
	"github.com/aroxu/tidy-engine/utils"
	"github.com/gin-contrib/sessions"
	"github.com/gin-contrib/sessions/cookie"
	"github.com/gin-gonic/gin"
	"github.com/kardianos/service"
)

var logger service.Logger
var dataDirPath = ""
var didRunOnBoot = false

// Program structures.
//  Define Start and Stop methods.
type program struct {
	exit chan struct{}
}

func (p *program) Start(s service.Service) error {
	if service.Interactive() {
		logger.Info("Running in terminal.")
	} else {
		logger.Info("Running under service manager.")
	}
	p.exit = make(chan struct{})

	// Start should not block. Do the actual work async.
	go p.run(dataDirPath)
	return nil
}
func (p *program) run(dataDirPath string) error {
	rand.Seed(time.Now().Unix())
	fmt.Println("loading File..")
	if err := config.Load(dataDirPath); err != nil {
		log.Fatal(err)
	}

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
	r.LoadHTMLGlob(dataDirPath + "templates/*/*.html")
	store := cookie.NewStore([]byte("secret"))
	r.Use(sessions.Sessions("mysession", store))
	routes.InitRoutes(r.Group(""))
	r.Run(":" + strconv.Itoa(int(config.Config.Port)))

	return nil
}
func (p *program) Stop(s service.Service) error {
	close(p.exit)
	return nil
}

func main() {
	flag := ""
	if len(os.Args) > 1 {
		flag = os.Args[1]
		if len(os.Args) > 2 {
			dataDirPath = os.Args[2]
		}
	}

	if dataDirPath == "" {
		dataDirPath = config.GetConfigDir()
	}

	options := make(service.KeyValue)
	options["Restart"] = "on-success"
	options["SuccessExitStatus"] = "1 2 8 SIGKILL"

	svcConfig := &service.Config{
		Name:        "TidyEngine",
		DisplayName: "Tidy Engine",
		Description: "Engine of tidy file share",
		Arguments:   []string{"dataDirPath", dataDirPath},
		Option:      options,
	}

	if runtime.GOOS != "windows" {
		svcConfig.Dependencies = []string{
			"Requires=network.target",
			"After=network-online.target syslog.target"}
	}

	prg := &program{}
	s, err := service.New(prg, svcConfig)
	if err != nil {
		log.Fatal(err)
	}
	errs := make(chan error, 5)
	logger, err = s.Logger(errs)
	if err != nil {
		log.Fatal(err)
	}

	go func() {
		for {
			err := <-errs
			if err != nil {
				log.Print(err)
			}
		}
	}()
	if runtime.GOOS != "windows" {
		if !utils.AmIRoot() {
			fmt.Println("Please run me again with root user or sudo")
			return
		}
	}

	status, _ := s.Status()
	switch flag {
	case "install":
		if err := service.Control(s, flag); err != nil {
			log.Fatal(err)
		}
		return
	case "start":
		if status == service.StatusStopped || status == service.StatusUnknown {
			if err := service.Control(s, flag); err != nil {
				log.Fatal(err)
			}
		} else {
			log.Fatal("Process is already started")
		}
		return
	case "stop":
		if status == service.StatusRunning || status == service.StatusUnknown {
			if err := service.Control(s, flag); err != nil {
				log.Fatal(err)
			}
		} else {
			log.Fatal("Process is already stopped")
		}
		return
	case "uninstall":
		if status == service.StatusRunning {
			fmt.Println("Stopping service before uninstall...")
			if err := service.Control(s, "stop"); err != nil {
				log.Fatal(err)
			}
		}
		if err = service.Control(s, flag); err != nil {
			log.Fatal(err)
		}
		return
	case "init":
		if err := utils.InitData(); err != nil {
			log.Fatal(err)
		}
		return
	case "status":
		if status == service.StatusRunning {
			fmt.Println("Process is running")
		} else if status == service.StatusStopped {
			fmt.Println("Process is stopped")
		} else {
			fmt.Println("Process is stopped or the service is not installed")
		}
		return
	case "version":
		fmt.Println("0.0.1")
		return
	case "dataDirPath":

	default:
		fmt.Println("engine (install|uninstall|start|stop|status|dataDirPath path/to/data/dir/|init)")
		return
	}

	if err := s.Run(); err != nil {
		logger.Error(err)
	}
}
