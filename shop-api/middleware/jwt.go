package middleware

import (
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/iying-cms/shop-api/config"
	"github.com/iying-cms/shop-api/models"
)

// JWTClaims JWT声明
type JWTClaims struct {
	UserID   uint `json:"user_id"`
	IsAdmin  bool `json:"is_admin"`
	Username string `json:"username"`
	jwt.RegisteredClaims
}

// GenerateToken 生成JWT令牌
func GenerateToken(user models.User) (string, string, error) {
	// 设置过期时间
	expireTime := time.Now().Add(config.AppConfig.JWT.Expire)
	expireTimeStr := expireTime.Format(time.RFC3339)
	
	// 创建声明
	claims := JWTClaims{
		UserID:   user.ID,
		IsAdmin:  user.IsAdmin == 1,
		Username: user.Username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expireTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Issuer:    "iying-shop-api",
			Subject:   user.Username,
		},
	}
	
	// 创建令牌
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	
	// 签名令牌
	tokenString, err := token.SignedString([]byte(config.AppConfig.JWT.Secret))
	if err != nil {
		return "", "", err
	}
	
	return tokenString, expireTimeStr, nil
}

// ParseToken 解析JWT令牌
func ParseToken(tokenString string) (*JWTClaims, error) {
	// 解析令牌
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(config.AppConfig.JWT.Secret), nil
	})
	
	if err != nil {
		return nil, err
	}
	
	// 验证令牌
	if claims, ok := token.Claims.(*JWTClaims); ok && token.Valid {
		return claims, nil
	}
	
	return nil, errors.New("invalid token")
}

// JWTAuth JWT认证中间件
func JWTAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 获取Authorization头
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
			c.Abort()
			return
		}
		
		// 检查Bearer前缀
		parts := strings.SplitN(authHeader, " ", 2)
		if !(len(parts) == 2 && parts[0] == "Bearer") {
			c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "无效的授权格式", nil))
			c.Abort()
			return
		}
		
		// 解析令牌
		claims, err := ParseToken(parts[1])
		if err != nil {
			c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "无效的令牌: "+err.Error(), nil))
			c.Abort()
			return
		}
		
		// 将用户信息存储到上下文
		c.Set("userID", claims.UserID)
		c.Set("isAdmin", claims.IsAdmin)
		c.Set("username", claims.Username)
		
		c.Next()
	}
}

// AdminAuth 管理员认证中间件
func AdminAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 先进行JWT认证
		JWTAuth()(c)
		
		// 如果已经中止，则直接返回
		if c.IsAborted() {
			return
		}
		
		// 检查是否为管理员
		isAdmin, exists := c.Get("isAdmin")
		if !exists || !isAdmin.(bool) {
			c.JSON(http.StatusForbidden, models.NewErrorResponse(http.StatusForbidden, "权限不足，需要管理员权限", nil))
			c.Abort()
			return
		}
		
		c.Next()
	}
} 