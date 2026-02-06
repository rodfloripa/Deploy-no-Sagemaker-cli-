# 1. Imagem base otimizada (Python slim)
FROM python:3.9-slim

# 2. Evita que o Python gere arquivos .pyc e permite logs em tempo real
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 3. Instala dependências mínimas do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 4. Define o diretório de trabalho padrão do SageMaker
WORKDIR /opt/ml/code

# 5. Instala o Toolkit de Inferência da AWS
# Ele gerencia o servidor HTTP e a comunicação com o SageMaker
RUN pip install --no-cache-dir sagemaker-inference gunicorn

# 6. COPIA APENAS o script necessário (Isso evita os 14GB)
# O Docker vai buscar o inference.py na sua pasta /home/rodney
COPY inference.py /opt/ml/code/inference.py

# 7. Caso você tenha um requirements.txt, descomente as linhas abaixo:
COPY requirements.txt /opt/ml/code/requirements.txt
RUN pip install --no-cache-dir -r /opt/ml/code/requirements.txt

# 8. Variáveis de ambiente para o SageMaker localizar o código
ENV SAGEMAKER_PROGRAM=inference.py
ENV SAGEMAKER_SUBMIT_DIRECTORY=/opt/ml/code

# 9. Exposição da porta padrão
EXPOSE 8080

# 10. Comando para iniciar o servidor de modelos
ENTRYPOINT ["python", "-m", "sagemaker_inference.model_server", "--model-dir", "/opt/ml/model"]
