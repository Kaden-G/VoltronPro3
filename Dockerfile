FROM node:14

# Set Flask environment variables
ENV FLASK_ENV='development'
ENV FLASK_APP='app.py'

# Set working directory
WORKDIR /app

# Copy package files and install Node.js dependencies
COPY package*.json ./
RUN npm install

# Install Python and pip dependencies
COPY requirements.txt .
RUN apt-get update \
    && apt-get install -y python3 python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose both Node.js and Flask ports
EXPOSE 3000 8080

# Run the Flask application
CMD ["node", "server.js"]
