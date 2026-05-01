from flask import Flask, render_template, jsonify, send_from_directory
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)

# Get configuration from environment variables
API_URL = os.getenv('API_URL')
SERVER_NUMBER = os.getenv('SERVER_NUMBER', '1')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/app.html')
def app_page():
    return render_template('app.html')

@app.route('/env.js')
def env_config():
    """Dynamically generate env.js from environment variables"""
    config = f"""const ENV = {{
  API_URL: '{API_URL}',
  SERVER_NUMBER: '{SERVER_NUMBER}'
}};
"""
    return app.response_class(config, mimetype='application/javascript')

@app.route('/styles.css')
def styles():
    return send_from_directory('static', 'styles.css')

@app.route('/auth.js')
def auth_js():
    return send_from_directory('static', 'auth.js')

@app.route('/app.js')
def app_js():
    return send_from_directory('static', 'app.js')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
