require('dotenv').config()
const express = require('express')
const morgan = require('morgan')
const cors = require('cors')
const todo = require('../routes/todo')
const notFound = require('../routes/http')
const error = require('../middleware/error')

const corsOptions = {
  origin: process.env.FRONTEND_URL,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type'],
}

module.exports = (app) => {
  app.disable('x-powered-by')
  app.use(cors(corsOptions))
  app.use(express.json())
  app.use(express.urlencoded({ extended: true }))
  app.use(morgan('tiny'))
  app.use('/api/todos', todo)
  app.use(notFound)
  app.use(error)
}
