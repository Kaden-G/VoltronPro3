// app.js

const express = require('express');
const mongoose = require('mongoose');
const multer = require('multer');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Connect to MongoDB (replace 'your-mongodb-uri' with your actual MongoDB URI)
mongoose.connect('your-mongodb-uri', { useNewUrlParser: true, useUnifiedTopology: true });

// Define a schema for storing file information in MongoDB
const fileSchema = new mongoose.Schema({
    filename: String,
    path: String,
    description: String,
});

const File = mongoose.model('File', fileSchema);

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
        // Save file information to MongoDB
        const newFile = new File({
            filename: req.file.originalname,
            path: req.file.path,
            description: req.body.description,
        });

        await newFile.save();
        res.status(201).send('File uploaded successfully.');
    } catch (error) {
        console.error(error);
        res.status(500).send('Internal Server Error');
