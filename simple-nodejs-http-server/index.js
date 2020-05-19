const dotenv = require('dotenv');
dotenv.config();

const express = require('express');
const app = express();
const port = Number(process.env.PORT);

app.get('', (req, res) => {
  res.send(process.env.SECRET);
});

app.get('/healthy', (req, res) => {
  res.status(200).end();
});

app.listen(port, () => {
  console.log('Logging in kubernetes pod, port: ' + port + '!');
});
