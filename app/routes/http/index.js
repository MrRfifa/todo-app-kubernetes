const express = require('express')
const router = express.Router()
const HttpStatus = require('../../utils/HttpStatus')

router.all('*', async (_req, res) => {
  res.status(HttpStatus.NotFound).send({ message: 'Page Not Found' })
})

module.exports = router
