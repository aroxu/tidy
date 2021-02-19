package utils

import (
	"os"
)

func AmIRoot() bool {
	if os.Getuid() == 0 {
		return true
	}
	return false
}
