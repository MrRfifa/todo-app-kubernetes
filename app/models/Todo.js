const mongoose = require('mongoose')

const todoSchema = new mongoose.Schema({
  title: String,
  description: String,
  completed: {
    type: Boolean,
    default: false,
  },
})

module.exports = mongoose.model('Todo', todoSchema)
