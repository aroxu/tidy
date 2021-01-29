package utils

import (
	"golang.org/x/crypto/bcrypt"
)

// CheckPassword check password
func CheckPassword(normal, hashed string) bool {
	verifyHash := []byte(hashed)
	err := bcrypt.CompareHashAndPassword(verifyHash, []byte(normal))
	if err != nil {
		return false
	}
	return true
}
