.PHONY: all build clean run test help

# 应用名称
APP_NAME=shop-api

# 版本号
VERSION=1.0.0

# Go命令
GO=go

# 构建目录
BUILD_DIR=./build

# 构建参数
BUILD_FLAGS=-ldflags "-X main.Version=$(VERSION)"

# 默认目标
all: build

# 构建应用
build:
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(BUILD_DIR)
	$(GO) build $(BUILD_FLAGS) -o $(BUILD_DIR)/$(APP_NAME) .

# 运行应用
run:
	@echo "Running $(APP_NAME)..."
	$(GO) run .

# 清理构建产物
clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR)
	@go clean

# 运行测试
test:
	@echo "Running tests..."
	$(GO) test -v ./...

# 初始化数据库
init-db:
	@echo "Initializing database..."
	@mysql -u root < database/init.sql

# 生成Swagger文档
swagger:
	@echo "Generating Swagger docs..."
	swag init

# 安装依赖
deps:
	@echo "Installing dependencies..."
	$(GO) mod tidy
	$(GO) get -u github.com/swaggo/swag/cmd/swag

# 显示帮助信息
help:
	@echo "Available commands:"
	@echo "  make build    - Build the application"
	@echo "  make run      - Run the application"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make test     - Run tests"
	@echo "  make init-db  - Initialize database"
	@echo "  make swagger  - Generate Swagger docs"
	@echo "  make deps     - Install dependencies" 