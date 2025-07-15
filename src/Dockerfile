FROM python:3.12-slim

WORKDIR /flask-docker

COPY requirements.txt /flask-docker/requirements.txt
COPY main.py /flask-docker/main.py
COPY templates /flask-docker/templates

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python","main.py"]
