package config

import (
	"encoding/json"
	"io/ioutil"
	"os"
	"runtime"
)

type ConfigStruct struct {
	Port      uint     `json:"port"`
	JwtSecret string   `json:"jwtSecret"`
	WhiteList []string `json:"whiteList"`
	BlackList []string `json:"usingWhiteList"`
}

type UserStruct struct {
	Name     string   `json:"name"`
	Password string   `json:"password"`
	Role     []string `json:"role"`
}

type FolderStruct struct {
	Name       string   `json:"name"`
	Path       string   `json:"path"`
	AccessRole []string `json:"accessRole"`
}

var (
	Config     ConfigStruct
	UserList   []UserStruct
	FolderList []FolderStruct
)

func GetConfigDir() string {
	path := ""
	if runtime.GOOS == "windows" {
		home := os.Getenv("HOMEDRIVE") + os.Getenv("HOMEPATH")
		if home == "" {
			home = os.Getenv("USERPROFILE")
		}
		path = home + "\\tidy\\data\\"
	} else {
		path = os.Getenv("HOME") + "/tidy/data/"
	}
	return path
}

func Load(configDirPath string) error {
	config, err := ioutil.ReadFile(configDirPath + "config.json")
	if err != nil {
		return err
	}
	if err := json.Unmarshal(config, &Config); err != nil {
		return err
	}
	configUser, err := ioutil.ReadFile(configDirPath + "user.json")
	if err != nil {
		return err
	}
	if err := json.Unmarshal(configUser, &UserList); err != nil {
		return err
	}
	configFolder, err := ioutil.ReadFile(configDirPath + "folder.json")
	if err != nil {
		return err
	}
	if err := json.Unmarshal(configFolder, &FolderList); err != nil {
		return err
	}

	return nil
}

func LoadUser(userName string) *UserStruct {
	for _, v := range UserList {
		if v.Name == userName {
			return &v
		}
	}
	return nil
}
