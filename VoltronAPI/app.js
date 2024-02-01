const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());  // Enable CORS
app.get('/employee', (req, res) => {
    // Handle GET logic
    res.status(200).json({ message: 'GET operation not implemented yet' });
});

app.post('/employee', (req, res) => {
    // Handle POST logic
    const data = req.body;
    // Implement logic to add data to DynamoDB or perform other actions
    res.status(201).json({ message: 'POST operation not implemented yet', data });
});

app.delete('/employee/:client/:asset_name', (req, res) => {
    // Handle DELETE logic
    const { client, asset_name } = req.params;
    // Implement logic to delete data from DynamoDB or perform other actions
    res.status(200).json({ message: 'DELETE operation not implemented yet', client, asset_name });
});

// Handle other routes
app.use((req, res) => {
    res.status(404).json({ error: 'Not Found' });
});

// Handle errors
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Internal Server Error' });
});

// Lambda handler
exports.lambdaHandler = async (event, context) => {
    const server = app.listen(3000, () => {
        console.log('Server is running on port 3000');
    });

    // Keep the server running until the Lambda function is terminated
    context.callbackWaitsForEmptyEventLoop = false;

    // Close the server when Lambda function is terminated
    context.done(() => {
        server.close();
    });
};
