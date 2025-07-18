package middleware

import (
	"github.com/gin-gonic/gin"
	"github.com/iying-cms/shop-api/config"
	"net/http"
	"strings"
)

// CORS 跨域中间件
func CORS() gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.Request.Header.Get("Origin")
		allowOrigins := config.AppConfig.CORS.AllowOrigins
		
		// 设置允许的源
		if allowOrigins == "*" {
			c.Header("Access-Control-Allow-Origin", origin)
		} else if isAllowedOrigin(origin, allowOrigins) {
			c.Header("Access-Control-Allow-Origin", origin)
		} else {
			c.Header("Access-Control-Allow-Origin", strings.Split(allowOrigins, ",")[0])
		}
		
		// 设置允许的请求头
		c.Header("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		
		// 设置允许的请求方法
		c.Header("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")
		
		// 设置是否允许携带凭证
		c.Header("Access-Control-Allow-Credentials", "true")
		
		// 处理预检请求
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		
		c.Next()
	}
}

// isAllowedOrigin 检查源是否在允许列表中
func isAllowedOrigin(origin, allowOrigins string) bool {
	if allowOrigins == "" {
		return false
	}
	
	for _, allowedOrigin := range strings.Split(allowOrigins, ",") {
		if strings.TrimSpace(allowedOrigin) == origin {
			return true
		}
	}
	
	return false
} 