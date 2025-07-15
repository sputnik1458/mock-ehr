from flask import Flask, redirect, render_template, url_for, jsonify, request
#import logging

app = Flask(__name__)
#logging.basicConfig(level=logging.INFO)
#app.logger.setLevel(logging.INFO)  # Set log level to INFO
#handler = logging.FileHandler('app.log')  # Log to a file
#app.logger.addHandler(handler)

@app.route('/patients',methods=['GET'])
def get_patients():
    data = [{"id": 1, "name": "Test Patient", "condition": "Fever"}]
 #   app.logger.info("Retrieved patient list")
    return jsonify(data)

@app.route('/submit', methods=['POST'])
def submit():
    message = request.form.get('nm')
  #  app.logger.info(f"Custom Log: {message}")
    #return jsonify({"{message}", "Logged"}), 200
    return f"<h2>Logged: {message}</h2><form action = '/' method = 'post'><p><input type = 'submit' value = 'back' /></p></form>"

@app.route('/', methods=['POST','GET'])
def view_form():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(host="127.0.0.1", port=8080,debug=True)
