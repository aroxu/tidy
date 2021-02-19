package config

import (
	"encoding/json"
	"io/ioutil"
	"os"
	"runtime"
)

type ConfigStruct struct {
	Name       string `json:"name"`
	Port       uint   `json:"port"`
	JwtSecret  string `json:"jwtSecret"`
	EnableAuth bool   `json:"enableAuth"`
}

type UserStruct struct {
	Name     string   `json:"name"`
	Password string   `json:"password"`
	Role     []string `json:"role"`
}

type FolderStruct struct {
	ID          string   `json:"id"`
	Name        string   `json:"name"`
	Description string   `json:"description"`
	Path        string   `json:"path"`
	AccessRole  []string `json:"accessRole"`
}

var (
	Config     *ConfigStruct
	UserList   []*UserStruct
	FolderList []*FolderStruct
)

var (
	GuestUser *UserStruct
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
	GuestUser = &UserStruct{
		Name:     "Guest",
		Password: "Guest",
		Role:     []string{"Guest"},
	}
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
			return v
		}
	}
	return nil
}

func LoadFolder(folderID string) *FolderStruct {
	for _, v := range FolderList {
		if v.ID == folderID {
			return v
		}
	}
	return nil
}

func CheckPermission(userRole *[]string, folderRole *[]string) bool {
	if !Config.EnableAuth {
		return true
	}
	for _, accessRole := range *folderRole {
		for _, userRole := range *userRole {
			if accessRole == userRole {
				return true
			}
		}
	}
	return false
}
