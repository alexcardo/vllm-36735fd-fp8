# Dockerfile
# Сборка vLLM из коммита 36735fd с поддержкой FP8 и nightly PyTorch

FROM nvidia/cuda:12.9.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHON_VERSION=3.12

# Установка системных зависимостей
RUN apt-get update && apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv \
    python3-pip \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1 \
    && ln -sf /usr/bin/python${PYTHON_VERSION}-config /usr/bin/python3-config

# Установка uv для быстрой установки пакетов
RUN pip3 install --no-cache-dir uv

# Клонирование vLLM на нужном коммите
WORKDIR /workspace
RUN git clone https://github.com/vllm-project/vllm.git .
RUN git checkout 36735fd77224467e6580f3bd48eb32d4fca8c72e

# Установка ночного PyTorch и зависимостей
ARG PYTORCH_NIGHTLY=1
RUN --mount=type=cache,target=/root/.cache/uv \
    if [ "${PYTORCH_NIGHTLY}" = "1" ]; then \
        uv pip install --system torch torchaudio torchvision --pre \
        --index-url https://download.pytorch.org/whl/nightly/cu129; \
    fi

RUN uv pip install --system -r requirements/cuda.txt

# Установка vLLM в режиме editable (компиляция CUDA ядер)
RUN uv pip install --system -e .

# Проверка установки
RUN python3 -c "import vllm; print(f'vLLM version: {vllm.__version__}')"

# ENTRYPOINT для удобного запуска
ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
