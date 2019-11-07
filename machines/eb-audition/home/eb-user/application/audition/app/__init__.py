from flask import Flask, session, render_template
from flask_session import Session
from app.api.employer import bp as employer_bp

app = Flask(__name__)
app.config.from_envvar('APP_CONFIG_FILE')
Session(app)

app.register_blueprint(employer_bp)


@app.route('/')
def home():
    return render_template('index.html')


@app.route('/login')
def login():
    session['logged_in'] = True
    session['role'] = []
    session['role'].append('user')

    return render_template('login.html')


@app.route('/logout')
def logout():
    session['logged_in'] = False
    session['role'] = []

    return render_template('logout.html')
