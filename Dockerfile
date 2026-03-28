# 1. Берем ту же базу, что была в nightly билдах того времени
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# 2. Ставим системные зависимости
RUN apt-get update && apt-get install -y git python3-pip ninja-build

# 3. Клонируем vLLM и переходим строго на твой коммит
RUN git clone https://github.com /vllm
WORKDIR /vllm
RUN git checkout 36735fd77224467e6580f3bd48eb32d4fca8c72e

# 4. СЕКРЕТ СБОРКИ БЕЗ GPU (чтобы не падало на GitHub):
# Мы говорим компилятору: "Не ищи карту, просто собери билд под эти архитектуры"
ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0+PTX"
ENV VLLM_TARGET_DEVICE=cuda
ENV MAX_JOBS=2

# 5. Устанавливаем зависимости и сам vLLM
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -v -e .

# 6. Твой конфиг требует flash-attn? Обычно он нужен.
RUN pip install --no-cache-dir flash-attn --no-build-isolation

# Твоя команда запуска остается прежней
ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
