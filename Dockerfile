FROM python:3.9.12-buster

# Set Flask environment variables
ENV FLASK_ENV='development'
ENV FLASK_APP='app.py'

# Set working directory
WORKDIR /usr/src/app

# Copy files into the working directory
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port
EXPOSE 8080

# Run the Flask application
CMD ["python", "app.py"]