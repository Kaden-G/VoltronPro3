from flask import Flask, request, jsonify
from flask_cors import CORS
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

app = Flask(__name__)
CORS(app)  # Enable CORS for all domains

# Configure DynamoDB connection
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('Voltron')  # Replace with your actual table name

@app.route('/submit_asset', methods=['POST'])
def submit_asset():
    try:
        data = request.json
        # Assuming 'clientUsername' and 'title' are included in the request body
        response = table.put_item(Item=data)
        return jsonify({"message": "Asset submitted successfully"}), 200
    except (NoCredentialsError, PartialCredentialsError, ClientError) as e:
        return jsonify({"error": str(e)}), 500

@app.route('/assets/<clientUsername>', methods=['GET'])
def get_assets(clientUsername):
    try:
        # Querying by partition key (clientUsername)
        response = table.query(
            KeyConditionExpression='clientUsername = :clientUsername',
            ExpressionAttributeValues={
                ':clientUsername': clientUsername
            }
        )
        return jsonify(response['Items']), 200
    except ClientError as e:
        return jsonify({"error": str(e)}), 500

@app.route('/health')
def health_check():
    return jsonify({"status": "healthy"}), 200
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)