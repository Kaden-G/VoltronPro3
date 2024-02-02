from flask import Flask, jsonify, request
from flask_cors import CORS
import boto3
from botocore.exceptions import ClientError
from flask import Flask, render_template

app = Flask(__name__)
CORS(app)

# Initialize a DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('DL-TEST')

# Get
@app.route('/item/<string:key>', methods=['GET'])
def get_item(key):
    try:
        response = table.get_item(Key={'PKEY': key})
    except ClientError as e:
        return jsonify({'error': str(e)}), 500
    else:
        item = response.get('Item')
        if not item:
            return jsonify({}), 404
        return jsonify(item)

# Post
@app.route('/item', methods=['POST'])
def create_item():
    item = request.json
    try:
        table.put_item(Item=item)
    except ClientError as e:
        return jsonify({'error': str(e)}), 500
    return jsonify(item), 201

# Delete
@app.route('/item/<string:key>', methods=['DELETE'])
def delete_item(key):
    try:
        table.delete_item(Key={'PKEY': key})
    except ClientError as e:
        return jsonify({'error': str(e)}), 500
    return jsonify({'message': 'Item deleted'}), 200

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)