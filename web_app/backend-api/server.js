const express = require('express');
const multer = require('multer');
const AWS = require('aws-sdk');
const s3Client = require('./s3Client');
require('dotenv').config();

const app = express();
const port = 3000;

// S3 bucket names
const TEMP_BUCKET = process.env.TEMP_BUCKET_NAME;
const FINAL_BUCKET = process.env.FINAL_BUCKET_NAME;

// Setup multer for file uploads.
const upload = multer({ storage: multer.memoryStorage() });

// Home page
app.get('/', (req, res) => {
  res.send(`
    <h1>Upload image</h1>
    <form method="post" enctype="multipart/form-data" action="/upload">
      <input type="file" name="image" />
      <button type="submit">Upload</button>
    </form>
  `);
});

// Upload endpoint.
app.post('/upload', upload.single('image'), async (req, res) => {
  if (!req.file) {
    return res.status(400).send('No file uploaded.');
  }

  const params = {
    Bucket: TEMP_BUCKET,
    Key: `uploads/${Date.now()}-${req.file.originalname}`,
    Body: req.file.buffer,
    ContentType: req.file.mimetype
  };

  try {
    await s3Client.putObject(params).promise();
    res.send('File uploaded successfully to Temp Bucket.');
  } catch (err) {
    console.error(err);
    res.status(500).send('Error uploading file.');
  }
});

// Results endpoint
app.get('/results', async (req, res) => {
  const params = {
    Bucket: FINAL_BUCKET
  };

  try {
    const data = await s3Client.listObjectsV2(params).promise();
    const images = data.Contents.map(obj => obj.Key);

    res.send(`
      <h1>Processed Images</h1>
      <ul>
        ${images.map(key => `<li>${key}</li>`).join('')}
      </ul>
    `);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error listing results.');
  }
});

// Start server
app.listen(port, () => {
  console.log(`Backend API running at http://localhost:${port}`);
});
