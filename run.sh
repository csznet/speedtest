#!/bin/bash

#========================= 配置 =========================#
URL="https://speed.cloudflare.com/__down?during=download&bytes=1073741824"
OUTPUT_FILE="cf_test_download"
#========================================================#

# 彩色输出
color_echo() {
    case $1 in
        red) COLOR='\033[0;31m' ;;
        green) COLOR='\033[0;32m' ;;
        yellow) COLOR='\033[1;33m' ;;
        blue) COLOR='\033[0;34m' ;;
        *) COLOR='\033[0m' ;;
    esac
    echo -e "${COLOR}${2}\033[0m"
}

# 是否为 root 用户
IS_ROOT=0
[ "$(id -u)" -eq 0 ] && IS_ROOT=1

#===================== 安装缺失依赖 =====================#
install_if_missing() {
    local cmd=$1
    local pkg=$2

    if ! command -v "$cmd" &>/dev/null; then
        color_echo yellow "🔧 缺少依赖：$cmd，正在尝试安装..."

        if [ -f /etc/debian_version ]; then
            if [ $IS_ROOT -eq 1 ]; then
                # 尝试仅安装，不强制更新，避免卡在失效源
                if ! apt install -y "$pkg"; then
                    color_echo red "❌ 安装 $pkg 失败。你可以尝试先修复源或手动运行：apt install $pkg"
                    exit 1
                fi
            else
                color_echo red "❌ 当前不是 root，且无 sudo。请手动安装：apt install $pkg"
                exit 1
            fi
        elif [ -f /etc/redhat-release ]; then
            if [ $IS_ROOT -eq 1 ]; then
                yum install -y "$pkg"
            else
                color_echo red "❌ 当前不是 root，且无 sudo。请手动安装：yum install $pkg"
                exit 1
            fi
        elif [ -f /etc/alpine-release ]; then
            if [ $IS_ROOT -eq 1 ]; then
                apk add "$pkg"
            else
                color_echo red "❌ 当前不是 root，且无 sudo。请手动安装：apk add $pkg"
                exit 1
            fi
        else
            color_echo red "❌ 不支持的系统，请手动安装 $pkg 后重试。"
            exit 1
        fi
    fi
}


install_if_missing wget wget
install_if_missing bc bc
install_if_missing aria2c aria2

#===================== 单线程测速 =====================#
color_echo blue "\n🚀 开始单线程测速 (wget)..."
START_TIME=$(date +%s.%N)
wget -O "$OUTPUT_FILE" "$URL" &> /dev/null
END_TIME=$(date +%s.%N)
DURATION=$(echo "$END_TIME - $START_TIME" | bc)
SIZE=$(stat -c %s "$OUTPUT_FILE" 2>/dev/null || wc -c < "$OUTPUT_FILE")
SPEED=$(echo "$SIZE / $DURATION / 1024 / 1024" | bc -l)
printf "📥 单线程下载速度: \033[1;32m%.2f MB/s\033[0m\n" "$SPEED"
rm -f "$OUTPUT_FILE"

#===================== 多线程测速 =====================#
color_echo blue "\n🚀 开始多线程测速 (aria2c -x 16)..."
START_TIME=$(date +%s.%N)
aria2c -x 16 -s 16 -o "$OUTPUT_FILE" "$URL" --summary-interval=1 --allow-overwrite=true --file-allocation=none &> /dev/null
END_TIME=$(date +%s.%N)
DURATION=$(echo "$END_TIME - $START_TIME" | bc)
SIZE=$(stat -c %s "$OUTPUT_FILE" 2>/dev/null || wc -c < "$OUTPUT_FILE")
SPEED=$(echo "$SIZE / $DURATION / 1024 / 1024" | bc -l)
printf "📥 多线程下载速度: \033[1;32m%.2f MB/s\033[0m\n" "$SPEED"
rm -f "$OUTPUT_FILE"

#===================== 完成 =====================#
color_echo green "\n🎉 测速完成！感谢使用！"
