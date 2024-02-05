const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const requestBody = JSON.parse(event.body);

    const params = {
        TableName: 'Voltron',
        Item: {
            clientUsername: requestBody.clientUsername,
            title: requestBody.title,
            mediaType: requestBody.mediaType
        }
    };

    try {
        await dynamodb.put(params).promise();

        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Asset submitted successfully' })
        };
    } catch (error) {
        console.error('Error submitting asset:', error);

        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error submitting asset' })
        };
    }
};
