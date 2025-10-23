FROM python:3.10-slim
WORKDIR /app
COPY ./app/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY ./app /app
EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app", "--workers=2", "--threads=4"]
