from flask import Flask, render_template
from flask_session import Session

app = Flask(__name__)
app.config.from_envvar('APP_CONFIG_FILE')
Session(app)


@app.route('/')
def home():
    return render_template('index.html')
