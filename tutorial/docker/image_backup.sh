#!/bin/bash

# 获取命令行参数，如果没有提供则使用默认值
BACKUP_DIR="${1:-./}"

echo BACKUP_DIR: "${BACKUP_DIR}"

# 确保备份目录存在
mkdir -p "$BACKUP_DIR"

# 获取所有镜像的列表
images=$(docker images --format "{{.Repository}}:{{.Tag}}")

# 循环遍历每个镜像
for image in $images; do
    # 镜像备份文件名，替换冒号和斜线为下划线
    filename=$(echo "$image" | sed 's/:/_/g; s/\//_/g')
    backup_file="${BACKUP_DIR}/${filename}.tar.gz"

    # 保存镜像到单独的tar文件中，并使用gzip压缩
    echo "Saving image $image to $backup_file..."

    # 检查保存操作是否成功
    if docker save "$image" | gzip > "$backup_file"; then
        echo "Image $image saved successfully."
    else
        echo "Failed to save image $image."
    fi
done

echo "All images have been processed."