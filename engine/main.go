package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"strconv"
	"strings"

	"github.com/aroxu/tidy-engine/config"
	"github.com/aroxu/tidy-engine/routes"
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
	fmt.Println("loading File..")
	if err := config.Load(dataDirPath); err != nil {
		log.Fatal(err)
	}

	r := gin.Default()
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

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])
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
		Arguments:   []string{"dataDirPath", dataDirPath, "--boot"},
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

	switch flag {
	case "install", "uninstall", "start", "stop":
		if err := service.Control(s, flag); err != nil {
			log.Fatal(err)
		}
		return
	case "status":
		status, err := s.Status()
		if err != nil {
			if strings.Contains(err.Error(), "Could not find service") {
				fmt.Println("Process is stopped or the service is not installed")
				return
			}
			log.Fatal(err)
		}
		switch status {
		case service.StatusRunning:
			fmt.Println("Process is running")
		case service.StatusStopped:
			fmt.Println("Process is stopped")
		}
		return

	case "dataDirPath", "":

	default:
		fmt.Println("tidy (install|uninstall|start|stop|status|dataDirPath path/to/data/dir/)")
		return
	}

	if err := s.Run(); err != nil {
		logger.Error(err)
	}
}
