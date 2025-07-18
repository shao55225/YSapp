#!/bin/bash

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}开始检查应用包体积...${NC}"

# 确保我们在项目根目录
cd "$(dirname "$0")/.." || exit

# 定义大小限制 (单位: 字节)
APK_SIZE_LIMIT=20000000 # 约20MB
AAB_SIZE_LIMIT=15000000 # 约15MB
IOS_SIZE_LIMIT=20000000 # 约20MB

# 构建Android应用包
echo -e "${YELLOW}构建Android应用包并分析大小...${NC}"
flutter build apk --target-platform android-arm64 --analyze-size > /tmp/apk_size_report.txt

# 提取APK大小
APK_SIZE=$(grep -oE "Final app size: [0-9.]+ MB \([0-9]+ bytes\)" /tmp/apk_size_report.txt | grep -oE "[0-9]+ bytes" | grep -oE "[0-9]+")

# 构建Android App Bundle
echo -e "${YELLOW}构建Android App Bundle并分析大小...${NC}"
flutter build appbundle --target-platform android-arm64 --analyze-size > /tmp/aab_size_report.txt

# 提取AAB大小
AAB_SIZE=$(grep -oE "Final bundle size: [0-9.]+ MB \([0-9]+ bytes\)" /tmp/aab_size_report.txt | grep -oE "[0-9]+ bytes" | grep -oE "[0-9]+")

# 检查是否在macOS上，如果是则构建iOS应用
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo -e "${YELLOW}构建iOS应用并分析大小...${NC}"
  flutter build ios --analyze-size > /tmp/ios_size_report.txt
  
  # 提取iOS大小
  IOS_SIZE=$(grep -oE "Final app size: [0-9.]+ MB \([0-9]+ bytes\)" /tmp/ios_size_report.txt | grep -oE "[0-9]+ bytes" | grep -oE "[0-9]+")
fi

# 输出结果
echo -e "\n${YELLOW}===== 包体积分析结果 =====${NC}"

if [ -n "$APK_SIZE" ]; then
  APK_SIZE_MB=$(echo "scale=2; $APK_SIZE/1048576" | bc)
  echo -e "APK大小: ${APK_SIZE_MB} MB"
  
  if [ "$APK_SIZE" -gt "$APK_SIZE_LIMIT" ]; then
    echo -e "${RED}⚠️ APK大小超过限制 ($(echo "scale=2; $APK_SIZE_LIMIT/1048576" | bc) MB)${NC}"
    echo -e "${YELLOW}建议优化:${NC}"
    echo "  - 压缩图片资源"
    echo "  - 移除未使用的资源和代码"
    echo "  - 使用代码混淆和压缩"
  else
    echo -e "${GREEN}✅ APK大小在限制范围内${NC}"
  fi
fi

if [ -n "$AAB_SIZE" ]; then
  AAB_SIZE_MB=$(echo "scale=2; $AAB_SIZE/1048576" | bc)
  echo -e "\nAAB大小: ${AAB_SIZE_MB} MB"
  
  if [ "$AAB_SIZE" -gt "$AAB_SIZE_LIMIT" ]; then
    echo -e "${RED}⚠️ AAB大小超过限制 ($(echo "scale=2; $AAB_SIZE_LIMIT/1048576" | bc) MB)${NC}"
    echo -e "${YELLOW}建议优化:${NC}"
    echo "  - 使用Android App Bundle分割资源"
    echo "  - 优化依赖项大小"
  else
    echo -e "${GREEN}✅ AAB大小在限制范围内${NC}"
  fi
fi

if [ -n "$IOS_SIZE" ]; then
  IOS_SIZE_MB=$(echo "scale=2; $IOS_SIZE/1048576" | bc)
  echo -e "\niOS应用大小: ${IOS_SIZE_MB} MB"
  
  if [ "$IOS_SIZE" -gt "$IOS_SIZE_LIMIT" ]; then
    echo -e "${RED}⚠️ iOS应用大小超过限制 ($(echo "scale=2; $IOS_SIZE_LIMIT/1048576" | bc) MB)${NC}"
    echo -e "${YELLOW}建议优化:${NC}"
    echo "  - 使用iOS bitcode"
    echo "  - 优化资源文件"
  else
    echo -e "${GREEN}✅ iOS应用大小在限制范围内${NC}"
  fi
fi

# 分析大文件和依赖项
echo -e "\n${YELLOW}===== 大文件分析 =====${NC}"
find . -path "./build" -prune -o -path "./.dart_tool" -prune -o -type f -size +500k -exec ls -lh {} \; | sort -k5 -hr | head -5

echo -e "\n${YELLOW}===== 依赖项大小分析 =====${NC}"
flutter pub deps --json | grep -oE '"name":"[^"]+","version":"[^"]+"' | sed 's/"name":"//;s/","version":"/ /;s/"$//' | sort

echo -e "\n${GREEN}包体积检查完成!${NC}"

# 分析报告的详细信息保存在临时文件中
echo -e "${YELLOW}详细的大小分析报告已保存到:${NC}"
echo "/tmp/apk_size_report.txt"
echo "/tmp/aab_size_report.txt"
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "/tmp/ios_size_report.txt"
fi 