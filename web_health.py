from flask import Flask
app = Flask(__name__)

@app.route('/health')
def health():
    return {'status': 'ok'}, 200

@app.route('/')
def root():
    return {'service': 'hermes-agent', 'status': 'running'}, 200

if __name__ == '__main__':
    import os
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)
