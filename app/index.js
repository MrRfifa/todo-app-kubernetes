const express = require('express');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const todoRoutes = require('./routes/todo');

const app = express();

app.use(bodyParser.json());

const mongoHost = process.env.MONGO_HOST || 'localhost';
const mongoPort = process.env.MONGO_PORT || 27017;

// Set up MongoDB connection
mongoose.connect(`mongodb://${mongoHost}:${mongoPort}/mydb`, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

app.use('/todos', todoRoutes);

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
