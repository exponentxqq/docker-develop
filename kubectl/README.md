# Kubectl

Kubernetes CLI 容器，基于 Ubuntu 构建，挂载 kubeconfig 实现集群管理。

## 镜像

- **基础镜像**: `ubuntu:22.04`（继承 `UBUNTU_VERSION`）
- **构建产物**: `docker-kubectl:1.34.1`
- **kubectl 版本**: 1.34.1（通过 `KUBECTL_VERSION` 环境变量控制）

## 安装方式

通过官方 checksum 验证后安装，确保二进制完整性：

```dockerfile
curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
```

## 挂载

| 宿主机路径        | 容器路径       | 说明              |
| ----------------- | -------------- | ----------------- |
| `kubectl/config/` | `/root/.kube/` | kubeconfig 及缓存 |

## 使用方式

```bash
# 启动
docker compose up -d kubectl

# 集群操作
./run.sh kubectl "kubectl get pods"
./run.sh kubectl "kubectl get nodes -o wide"
./run.sh kubectl "kubectl apply -f deployment.yaml"

# 切换 context
./run.sh kubectl "kubectl config get-contexts"
./run.sh kubectl "kubectl config use-context <name>"

# 交互式 shell
docker exec -it kubectl bash
```

## 配置说明

将 kubeconfig 文件放入 `kubectl/config/` 目录：

- `kubectl/config/config` — kubeconfig 文件（YAML）
- `kubectl/config/cache/` — Kubectl 缓存目录
