# БАЗОВЫЙ ОБРАЗ: CUDA 12.9.1 (как в оригинальном коммите)
FROM nvidia/cuda:12.9.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
# BLACKWELL 12.0 + ВСЕ ОСТАЛЬНЫЕ
ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0;12.0+PTX"
ENV VLLM_TARGET_DEVICE=cuda

RUN apt-get update && apt-get install -y \
    git \
    python3-pip \
    ninja-build \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /vllm
RUN git clone https://github.com/vllm-project/vllm.git .

RUN git checkout 36735fd77224467e6580f3bd48eb32d4fca8c72e

RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir "cmake>=3.21"

# NIGHTLY PYTORCH С CUDA 12.9
RUN pip install --no-cache-dir torch torchaudio torchvision --pre \
    --index-url https://download.pytorch.org/whl/nightly/cu129

RUN pip install --no-cache-dir -v -e .

ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
