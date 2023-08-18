const mongoose = require('mongoose');

const todoSchema = new mongoose.Schema({
  title: String,
  description: String,
  completed: Boolean,
});

module.exports = mongoose.model('Todo', todoSchema);
