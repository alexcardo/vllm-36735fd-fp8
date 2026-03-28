FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0+PTX"
ENV VLLM_TARGET_DEVICE=cuda

RUN apt-get update && apt-get install -y git python3-pip ninja-build && rm -rf /var/lib/apt/lists/*

# ИСПРАВЛЕННАЯ СТРОКА:
RUN git clone https://github.com/vllm
WORKDIR /vllm
RUN git checkout 36735fd77224467e6580f3bd48eb32d4fca8c72e

RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir cmake >= 3.21

# Собираем vLLM (это будет долго!)
RUN pip install --no-cache-dir -v -e .

ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
