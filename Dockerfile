FROM python:3.12-slim

WORKDIR /app

RUN useradd -r -s /sbin/nologin appuser

COPY app.py .

USER appuser

EXPOSE 8000

CMD ["python", "-u", "app.py"]
