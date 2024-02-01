const express = require('express');
const aws = require('aws-sdk');
const multer = require('multer');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Configure AWS SDK
aws.config.update({
  region: 'us-east-1', // Replace with your AWS region
});

const dynamoDB = new aws.DynamoDB.DocumentClient();

const fileSchema = {
  TableName: 'Voltron', // Replace with your DynamoDB table name
  KeySchema: [
    { AttributeName: 'filename', KeyType: 'HASH' },
  ],
  AttributeDefinitions: [
    { AttributeName: 'filename', AttributeType: 'S' },
  ],
  ProvisionedThroughput: {
    ReadCapacityUnits: 5,
    WriteCapacityUnits: 5,
  },
};

// Create DynamoDB table if not exists
dynamoDB.createTable(fileSchema, (err, data) => {
  if (err) {
    console.error('Error creating table', err);
  } else {
    console.log('Table created successfully', data);
  }
});

// Configure Multer for file uploads
const storage = multer.diskStorage({
  destination: './uploads/',
  filename: function (req, file, cb) {
    cb(null, file.originalname);
  },
});

const upload = multer({ storage: storage });

// Serve static files from the 'uploads' directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// API endpoint to handle file upload
app.post('/upload', upload.single('file'), async (req, res) => {
  try {
    // Save file information to DynamoDB
    const params = {
      TableName: 'Voltron', // Replace with your DynamoDB table name
      Item: {
        filename: req.file.originalname,
        path: req.file.path,
        description: req.body.description,
      },
    };

    await dynamoDB.put(params).promise();
    res.status(201).send('File uploaded successfully.');
  } catch (error) {
    console.error(error);
    res.status(500).send('Internal Server Error');
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
