package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/iying-cms/shop-api/config"
	"github.com/iying-cms/shop-api/database"
	"github.com/iying-cms/shop-api/routes"
)

// @title 爱影视频商城API
// @version 1.0
// @description 爱影视频APP商城系统和第三方站点管理API
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.url http://www.example.com/support
// @contact.email support@example.com

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8080
// @BasePath /
// @schemes http https

// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name Authorization

func main() {
	// 加载配置
	if err := config.LoadConfig(); err != nil {
		log.Fatalf("加载配置失败: %v", err)
	}

	// 初始化数据库
	if err := database.Initialize(); err != nil {
		log.Fatalf("初始化数据库失败: %v", err)
	}

	// 初始化路由
	r := routes.SetupRouter()

	// 启动服务器
	go func() {
		port := fmt.Sprintf(":%d", config.AppConfig.Server.Port)
		if err := r.Run(port); err != nil {
			log.Fatalf("启动服务器失败: %v", err)
		}
	}()

	// 等待中断信号优雅关闭服务器
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("正在关闭服务器...")

	// 关闭数据库连接
	database.Close()
	log.Println("服务器已关闭")
} 