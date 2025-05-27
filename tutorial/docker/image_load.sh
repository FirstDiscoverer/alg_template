#!/bin/bash

# 获取命令行参数，如果没有提供则使用默认值
BACKUP_DIR="${1:-./}"

echo BACKUP_DIR: "${BACKUP_DIR}"

# 检查备份目录是否存在
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory does not exist: $BACKUP_DIR"
    exit 1
fi

# 切换到备份目录
cd "$BACKUP_DIR" || exit

# 遍历备份目录中的所有.tar.gz文件
for file in *.tar.gz; do
    if [ -f "$file" ]; then  # 确保是文件
        echo "Loading image from $file..."

        # 使用docker load命令导入镜像
        if gunzip -c "$file" | docker load; then
            echo "Image loaded successfully from $file."
        else
            echo "Failed to load image from $file."
        fi
    fi
done

echo "All images have been processed."