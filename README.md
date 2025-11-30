
# Kind Image Loader

一个 Bash 脚本，用于将本地 Docker 镜像快速加载到 Kind Kubernetes 集群。

## 功能

- 检查本地镜像是否存在，未存在则自动 pull
- 将镜像加载到所有 Kind worker 节点
- 验证镜像是否成功导入

## 使用方法

# 克隆仓库
git clone https://github.com/你的用户名/kind-image-loader.git
cd kind-image-loader

# 给脚本加执行权限
chmod +x kind_img_v2.sh

# 使用示例
./kind_img_v2.sh <cluster_name> <image1[:tag]> [<image2[:tag]> ...]
# 例如
./kind_img_v2.sh k8s nginx:1.22.0 busybox:1.28

## 示例文件
examples/sample_run.sh 提供了一些运行示例。

##注意事项

需要安装 kind、docker、kubectl

确保目标 Kind 集群已存在

脚本会在任意命令失败时停止运行 (set -e)
