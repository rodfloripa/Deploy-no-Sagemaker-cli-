FROM python:3.9-slim

# Variáveis de ambiente
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /opt/ml/code

# 1. Copia primeiro apenas o arquivo de dependências
COPY requirements.txt /opt/ml/code/requirements.txt

# 2. Instala as dependências (incluindo Flask e Gunicorn se estiverem no arquivo)
# Caso não estejam no requirements.txt, mantive a instalação explícita abaixo
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn flask

# 3. Copia o restante do código
COPY inference.py /opt/ml/code/inference.py

EXPOSE 8080

ENTRYPOINT ["gunicorn", "-b", "0.0.0.0:8080", "inference:app"]
