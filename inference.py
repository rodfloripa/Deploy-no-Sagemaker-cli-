import json
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def model_fn(model_dir):
    logger.info("Modelo carregado com sucesso (dummy).")
    return {}

def predict_fn(input_data, model):
    logger.info(f"Dados recebidos no predict: {input_data}")
    
    # Se o input_data vier como string (às vezes acontece), tentamos carregar
    if isinstance(input_data, str):
        input_data = json.loads(input_data)
    
    # Busca a chave 'input' ou 'mensagem'
    texto = input_data.get('input', input_data.get('mensagem', 'sem conteúdo'))
    
    return {'resultado': f'Mensagem recebida: {texto}'}
