const dotenv = require('dotenv');
dotenv.config();

const fs = require('fs');
const express = require('express');
const app = express();
const port = Number(process.env.PORT);

const envPath = '.env';
const envvPath = '.envv';

app.get('', (req, res) => {
	res.send(process.env.SECRET);
});

app.get('/healthy', (req, res) => {
	res.status(fs.existsSync(envPath) ? 200 : 500).end();
});

app.get('/hide', (req, res) => {
	fs.renameSync(envPath, envvPath);
	console.log('.env hidden');
	res.status(200).end();
});

app.get('/show', (req, res) => {
	fs.renameSync(envvPath, envPath);
	console.log('.env visible');
	res.status(200).end();
});

app.get('/collapse', (req, res) => {
	let x = 0;
	while (true) {
		x += 1000000;
	}
});

app.listen(port, () => {
	console.log('Logging in kubernetes pod, port: ' + port + '!');
});
