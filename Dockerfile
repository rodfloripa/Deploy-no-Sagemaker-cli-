FROM python:3.9-slim

# Instala o Flask e o Gunicorn (servidor web robusto)
RUN pip install --no-cache-dir flask gunicorn

WORKDIR /opt/ml/code
COPY inference.py /opt/ml/code/inference.py

# Variáveis de ambiente
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

EXPOSE 8080

# Inicia o servidor usando Gunicorn
ENTRYPOINT ["gunicorn", "-b", "0.0.0.0:8080", "inference:app"]
