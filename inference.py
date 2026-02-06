import json

def model_fn(model_dir):
    # Não é necessário para este exemplo
    pass

def input_fn(request_body, request_content_type):
    if request_content_type == 'application/json':
        data = json.loads(request_body)
        return data
    else:
        raise ValueError('Content type não suportado')

def predict_fn(input_data, model):
    mensagem = input_data.get('mensagem', '')
    return f'Mensagem recebida: {mensagem}'

def output_fn(prediction, accept):
    if accept == 'application/json':
        return json.dumps({'mensagem': prediction})
    else:
        raise ValueError('Accept não suportado')
