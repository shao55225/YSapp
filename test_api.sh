#!/bin/bash

# 检查是否安装了jq
if ! command -v jq &> /dev/null; then
    echo "jq未安装，正在安装..."
    yum install -y jq || apt-get install -y jq
fi

# 测试第三方站点API
echo "测试第三方站点API (无认证):"
curl -s http://localhost:21007/api/v1/sites/available | jq .

# 获取认证令牌 (假设有登录API)
echo -e "\n尝试获取认证令牌:"
TOKEN=$(curl -s -X POST http://localhost:21007/api/v1/auth/login -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}' | jq -r '.data.token')

if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
    echo "获取到令牌: ${TOKEN:0:20}..."
    
    # 使用令牌测试第三方站点API
    echo -e "\n使用令牌测试第三方站点API:"
    curl -s http://localhost:21007/api/v1/sites/available -H "Authorization: Bearer $TOKEN" | jq .
    
    # 测试商城API
    echo -e "\n测试商城API (商品列表):"
    curl -s http://localhost:21007/api/v1/shop/products -H "Authorization: Bearer $TOKEN" | jq .
else
    echo "未能获取令牌，尝试使用固定令牌"
    
    # 使用固定令牌测试
    echo -e "\n使用固定令牌测试第三方站点API:"
    curl -s http://localhost:21007/api/v1/sites/available -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3MzIwNTQ0MDB9.8Mg_yN8qV8FXybo3lrn8BZ24fvDJP3r9" | jq .
    
    echo -e "\n测试商城API (商品列表):"
    curl -s http://localhost:21007/api/v1/shop/products -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3MzIwNTQ0MDB9.8Mg_yN8qV8FXybo3lrn8BZ24fvDJP3r9" | jq .
fi
