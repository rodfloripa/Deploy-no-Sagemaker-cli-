import flask
import json
import sys

# Criamos a aplicação Flask
app = flask.Flask(__name__)

@app.route('/ping', methods=['GET'])
def ping():
    """O SageMaker chama este endpoint para verificar se o container está vivo."""
    return flask.Response(response='\n', status=200, mimetype='application/json')

@app.route('/invocations', methods=['POST'])
def invocations():
    """O SageMaker chama este endpoint para obter previsões."""
    # Pegamos o corpo bruto da requisição para logar em caso de erro
    raw_data = flask.request.data.decode('utf-8')
    print(f"DEBUG - Recebido bruto: {raw_data}", file=sys.stderr)

    try:
        # Tentativa 1: Forçar o parse do JSON
        data = flask.request.get_json(force=True, silent=True)
        
        # Tentativa 2: Se o Flask falhou, tentamos o json.loads manual
        if data is None:
            data = json.loads(raw_data)
            
        mensagem = data.get('input', 'vazio')
        status_code = 200
        result = {
            "resultado": f"Sucesso total: {mensagem}",
            "status": "processado"
        }
        
    except Exception as e:
        # Se tudo falhar, retornamos o erro para você ver no terminal
        print(f"ERRO - Falha ao processar: {str(e)}", file=sys.stderr)
        result = {"erro": str(e), "recebido": raw_data}
        status_code = 400

    return flask.Response(
        response=json.dumps(result), 
        status=status_code, 
        mimetype='application/json'
    )

if __name__ == '__main__':
    # O SageMaker exige que o servidor rode na porta 8080
    app.run(host='0.0.0.0', port=8080)
