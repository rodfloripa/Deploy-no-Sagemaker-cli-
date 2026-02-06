import flask
import json

app = flask.Flask(__name__)

@app.route('/ping', methods=['GET'])
def ping():
    return flask.Response(response='\n', status=200, mimetype='application/json')

@app.route('/invocations', methods=['POST'])
def invocations():
    data = flask.request.get_json()
    mensagem = data.get('input', 'vazio')
    result = {"resultado": f"Sucesso total: {mensagem}"}
    return flask.Response(response=json.dumps(result), status=200, mimetype='application/json')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
