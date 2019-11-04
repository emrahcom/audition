from flask import Flask, render_template
from flask_session import Session
from app.api.employer import bp as employer_bp

app = Flask(__name__)
app.config.from_envvar('APP_CONFIG_FILE')
Session(app)

app.register_blueprint(employer_bp)


@app.route('/')
def home():
    return render_template('index.html')
