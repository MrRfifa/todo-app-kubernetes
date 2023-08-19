const express = require('express')
const router = express.Router()
const Todo = require('../../models/Todo')
const HttpStatus = require('../../utils/HttpStatus')

// Create a new todo
router.post('/', async (req, res) => {
  try {
    const todo = new Todo(req.body)
    await todo.save()
    res.status(HttpStatus.Created).send(todo)
  } catch (error) {
    res.status(HttpStatus.BadRequest).send(error)
  }
})

// Get all todos
router.get('/', async (_req, res) => {
  try {
    const todos = await Todo.find({})
    res.status(HttpStatus.OK).send(todos)
  } catch (error) {
    res.status(HttpStatus.InternalServerError).send(error)
  }
})

// Update a todo by ID
router.put('/:id', async (req, res) => {
  try {
    const todo = await Todo.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    })
    res.status(HttpStatus.OK).send(todo)
  } catch (error) {
    res.status(HttpStatus.BadRequest).send(error)
  }
})

// Delete a todo by ID
router.delete('/:id', async (req, res) => {
  try {
    const todo = await Todo.findByIdAndDelete(req.params.id)
    res.send(todo)
  } catch (error) {
    res.status(HttpStatus.InternalServerError).send(error)
  }
})

module.exports = router
