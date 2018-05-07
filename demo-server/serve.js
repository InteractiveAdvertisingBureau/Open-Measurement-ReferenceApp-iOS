const express = require('express')
const app = express()
var port = 8787

app.use('/', express.static(__dirname + '/'));

app.listen(port, () => console.log('Listening at http://localhost:' + port))