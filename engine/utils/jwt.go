package utils

import (
	"fmt"
	"time"

	"github.com/aroxu/tidy-engine/config"
	"github.com/dgrijalva/jwt-go"
)

type JWTClaims struct {
	UserName string
	jwt.StandardClaims
}

func CreateJwtToken(userName string) (string, error) {
	expirationTime := time.Now().Add(time.Hour * 2)

	claims := &JWTClaims{
		UserName: userName,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expirationTime.Unix(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(config.Config.JwtSecret))

	if err != nil {
		return "", fmt.Errorf("token signed Error")
	}
	return tokenString, nil
}
