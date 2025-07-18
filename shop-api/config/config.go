package config

import (
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

// Config 应用配置
type Config struct {
	DB      DBConfig
	Server  ServerConfig
	JWT     JWTConfig
	CORS    CORSConfig
	Logging LoggingConfig
}

// DBConfig 数据库配置
type DBConfig struct {
	Host     string
	Port     int
	User     string
	Password string
	Name     string
	Charset  string
}

// ServerConfig 服务器配置
type ServerConfig struct {
	Port int
	Mode string
}

// JWTConfig JWT配置
type JWTConfig struct {
	Secret string
	Expire time.Duration
}

// CORSConfig 跨域配置
type CORSConfig struct {
	AllowOrigins string
}

// LoggingConfig 日志配置
type LoggingConfig struct {
	Level string
	File  string
}

// DSN 获取数据库连接字符串
func (c *DBConfig) DSN() string {
	return fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=%s&parseTime=True&loc=Local",
		c.User, c.Password, c.Host, c.Port, c.Name, c.Charset)
}

var AppConfig Config

// LoadConfig 加载配置
func LoadConfig() error {
	// 尝试从.env文件加载配置
	_ = godotenv.Load()

	// 数据库配置
	dbPort, _ := strconv.Atoi(getEnv("DB_PORT", "3306"))
	AppConfig.DB = DBConfig{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     dbPort,
		User:     getEnv("DB_USER", "root"),
		Password: getEnv("DB_PASSWORD", ""),
		Name:     getEnv("DB_NAME", "iyingcms"),
		Charset:  getEnv("DB_CHARSET", "utf8mb4"),
	}

	// 服务器配置
	serverPort, _ := strconv.Atoi(getEnv("SERVER_PORT", "8080"))
	AppConfig.Server = ServerConfig{
		Port: serverPort,
		Mode: getEnv("SERVER_MODE", "debug"),
	}

	// JWT配置
	jwtExpire, _ := time.ParseDuration(getEnv("JWT_EXPIRE", "24h"))
	AppConfig.JWT = JWTConfig{
		Secret: getEnv("JWT_SECRET", "iying_shop_api_secret_key"),
		Expire: jwtExpire,
	}

	// 跨域配置
	AppConfig.CORS = CORSConfig{
		AllowOrigins: getEnv("ALLOW_ORIGINS", "*"),
	}

	// 日志配置
	AppConfig.Logging = LoggingConfig{
		Level: getEnv("LOG_LEVEL", "debug"),
		File:  getEnv("LOG_FILE", "./logs/shop-api.log"),
	}

	return nil
}

// getEnv 获取环境变量，如果不存在则返回默认值
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
} 