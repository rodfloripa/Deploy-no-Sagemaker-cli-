import json
import logging

# Configura logs para que você veja erros no CloudWatch
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def model_fn(model_dir):
    logger.info("Iniciando carregamento do modelo...")
    # Retornamos um dicionário vazio apenas para o SageMaker não reclamar
    return {}

def input_fn(request_body, request_content_type):
    logger.info(f"Recebendo dados: {request_content_type}")
    if request_content_type == 'application/json':
        return json.loads(request_body)
    return request_body

def predict_fn(input_data, model):
    logger.info(f"Processando input: {input_data}")
    # Usamos .get() com um fallback para 'input' ou 'mensagem'
    # Assim aceitamos qualquer um dos dois formatos
    texto = input_data.get('input', input_data.get('mensagem', 'vazio'))
    return f'Mensagem recebida com sucesso: {texto}'

def output_fn(prediction, accept):
    return json.dumps({'resultado': prediction}), 'application/json'
