# LiteLLM

LLM API 网关，统一代理多个大模型供应商，提供 OpenAI 兼容 API，支持自动降级。

## 镜像

- **镜像**: `ghcr.io/berriai/litellm:main-latest`（官方 main 分支最新版，无需本地构建）
- **容器名**: `litellm`

## 架构

```
编辑器 / CLI / 应用
       │
       ▼
 LiteLLM (port 4000)
       │
       ├── haiku   → DeepSeek V4 Flash
       ├── sonnet  → DeepSeek V4 Pro
       ├── opus    → DeepSeek V4 Pro
       ├── zai-glm-4.7 / 5 / 5.1
       ├── deepseek-v4-flash / deepseek-v4-pro
       └── qwen3-coder-next / qwen3-coder-plus / qwen-glm-5 / qwen3-max-thinking
```

## 端口

| 端口 | 用途                             |
| ---- | -------------------------------- |
| 4000 | LiteLLM API，映射到宿主机 `4000` |

## 模型别名映射

为兼容 Claude Code 的原生模型名，配置了 `model_group_alias`：

| Claude Code 模型    | 映射到 | 实际模型          |
| ------------------- | ------ | ----------------- |
| `claude-sonnet-4-6` | sonnet | DeepSeek V4 Pro   |
| `claude-sonnet-4-5` | sonnet | DeepSeek V4 Pro   |
| `claude-haiku-4-5`  | haiku  | DeepSeek V4 Flash |
| `claude-opus-4-6`   | opus   | DeepSeek V4 Pro   |

## 自动降级

当主模型不可用时（欠费、429、资源不足），自动降级到可用模型：

| 主模型 | 降级模型         |
| ------ | ---------------- |
| haiku  | qwen3-coder-next |
| sonnet | qwen3-coder-plus |
| opus   | qwen-glm-5       |

## 环境变量

| 变量                | 说明                                                                                      |
| ------------------- | ----------------------------------------------------------------------------------------- |
| `DEEPSEEK_API_KEY`  | DeepSeek API 密钥                                                                         |
| `QWEN_API_KEY`      | 通义千问 API 密钥                                                                         |
| `DASHSCOPE_API_KEY` | 阿里云 DashScope API 密钥                                                                 |
| `ZAI_API_KEY`       | 智谱 Z.AI API 密钥                                                                        |
| `ZAI_API_BASE`      | Z.AI 网关地址（编码订阅默认走 coding 网关；按量/通用设为 `https://api.z.ai/api/paas/v4`） |

## 使用方式

```bash
# 启动
docker compose up -d litellm

# 查看日志
docker compose logs -f litellm

# 健康检查
curl http://localhost:4000/health/liveliness

# 测试调用
curl -X POST http://localhost:4000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "sonnet", "messages": [{"role": "user", "content": "Hello"}]}'

# 重启
docker compose restart litellm
```

## 配置更新

编辑 `litellm/config.yaml` 后重启容器即可生效：

```bash
vim litellm/config.yaml
docker compose restart litellm
```

## 配置参数

| 参数                   | 值                       | 说明           |
| ---------------------- | ------------------------ | -------------- |
| `drop_params: true`    | 自动丢弃模型不支持的参数 | 兼容不同 API   |
| `modify_params: true`  | 自动转换请求格式         | 适配供应商差异 |
| `request_timeout: 600` | 10 分钟超时              | 支持长推理     |
