FROM python:3.11-slim

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app.py .
COPY .env .
COPY templates/ templates/
COPY static/ static/

# Expose port
EXPOSE 80

# Run with gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:80", "--workers", "2", "app:app"]
