from flask import Flask, request, jsonify
from flask_cors import CORS
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

app = Flask(__name__)
CORS(app)  # Enable CORS for all domains

# Configure DynamoDB connection
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('dl-test-full')  # Replace with your actual table name

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

@app.route('/assets/<clientUsername>/<title>', methods=['GET', 'DELETE'])
def handle_asset(clientUsername, title):
    if request.method == 'GET':
        try:
            response = table.get_item(
                Key={'clientUsername': clientUsername, 'title': title}
            )
            if 'Item' in response:
                return jsonify(response['Item']), 200
            else:
                return jsonify({"error": "Asset not found"}), 404
        except ClientError as e:
            return jsonify({"error": str(e)}), 500
    elif request.method == 'DELETE':
        try:
            table.delete_item(
                Key={'clientUsername': clientUsername, 'title': title}
            )
            return jsonify({"message": "Asset deleted successfully"}), 200
        except ClientError as e:
            return jsonify({"error": str(e)}), 500
@app.route('/health')
def health_check():
    return jsonify({"status": "healthy"}), 200
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)