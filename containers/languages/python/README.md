# Python

Conda + UV 双工具链 Python 开发容器，一套环境覆盖数据处理、Web 后端、AI/ML 和脚本工具全场景。

## 镜像

- **基础镜像**: `continuumio/miniconda3:24.11.1-0`（通过 `CONDA_VERSION` 环境变量控制）
- **构建产物**: `docker-python:24.11.1-0`

## 双工具链设计

| 工具      | 定位                | 典型场景                                     |
| --------- | ------------------- | -------------------------------------------- |
| **Conda** | 环境管理 + AI/ML 包 | NumPy, PyTorch, TensorFlow, conda-forge 生态 |
| **UV**    | 快速依赖解析和安装  | 日常 pip 包、Web 框架、CLI 工具              |

工作流：

- 用 `conda create -n <name> python=<ver>` 创建项目环境
- 在环境内用 `uv pip install` 安装依赖（速度比 pip 快 10-100x）
- Conda 管理 Python 版本和二进制依赖，UV 管理纯 Python 包

## 预装系统工具

| 工具                                    | 用途                                 |
| --------------------------------------- | ------------------------------------ |
| build-essential, libssl-dev, libffi-dev | 编译 Python 扩展                     |
| libmariadb-dev, libpq-dev               | MySQL / PostgreSQL 客户端库          |
| libreoffice, poppler-utils              | 文档转换（Office → PDF，PDF → 文本） |
| libopenblas-dev, liblapack-dev          | 科学计算（NumPy/SciPy 的 BLAS 后端） |
| AWS CLI v2                              | 云资源管理                           |
| git, vim, zsh, curl, wget               | 开发工具                             |

## Conda 配置

- **Channel**: `conda-forge` 已添加，`channel_priority: flexible`
- **环境存储**: `~/.conda/envs/`（通过 `conda-envs` named volume 持久化）
- **包缓存**: `~/.conda/pkgs/`（宿主机 `cache/conda-pkgs` 挂载）

## 端口

| 端口 | 用途              |
| ---- | ----------------- |
| 5000 | 默认 Web 应用端口 |

## 挂载

| 宿主机路径                  | 容器路径                    | 说明             |
| --------------------------- | --------------------------- | ---------------- |
| `${HOST_PROJECT_PATH}`      | `${CONTAINER_PROJECT_PATH}` | 项目代码         |
| `common/.zshrc`             | `/home/docker/.zshrc`       | Zsh 配置         |
| `common/.vimrc`             | `/home/docker/.vimrc`       | Vim 配置         |
| `${DATA_PATH}`              | `/data`                     | 数据目录         |
| `python/aws/`               | `/home/docker/.aws`         | AWS 凭证和配置   |
| `conda-envs` (named volume) | `/home/docker/.conda/envs`  | Conda 环境持久化 |
| `cache/conda-pkgs`          | `/home/docker/.conda/pkgs`  | Conda 包缓存     |
| `cache/uv-cache`            | `/home/docker/.cache/uv`    | UV 包缓存        |

## 使用方式

```bash
# 启动
docker compose up -d python

# 创建 Conda 环境
./run.sh python "conda create -n myproject python=3.12 -y"
./run.sh python "conda activate myproject"

# 使用 UV 安装依赖（在 Conda 环境内）
./run.sh python "bash -c 'source ~/miniconda3/etc/profile.d/conda.sh && conda activate myproject && uv pip install numpy pandas'"

# 运行 Python 脚本
./run.sh python "python script.py"
./run.sh python "python -m pytest"

# Jupyter（如已安装）
./run.sh python "jupyter lab --ip 0.0.0.0 --port 5000"

# AWS CLI
./run.sh python "aws s3 ls"

# 交互式 shell
docker exec -it python bash
```

## Conda 环境管理

```bash
# 列出所有环境
conda env list

# 删除环境
conda env remove -n myproject

# 导出环境
conda env export -n myproject > environment.yml
```

## 项目级别 Python 版本

每个项目自行管理 Python 版本，不在容器层面锁定：

- 数据科学项目：`conda create -n myds python=3.11 numpy pandas scipy`
- Web 后端：`conda create -n myweb python=3.12 fastapi uvicorn`
- 脚本工具：`conda create -n mytool python=3.13`
