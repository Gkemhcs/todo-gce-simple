const express = require('express');
const app = express();

app.set('view engine', 'ejs');
app.use(express.urlencoded({ extended: true }));

let tasks = [];

app.get('/', (req, res) => {
  res.render('index', { tasks });
});

app.post('/addTask', (req, res) => {
  const { task } = req.body;
  tasks.push(task);
  res.redirect('/');
});

app.post('/deleteTask', (req, res) => {
  const { index } = req.body;
  tasks.splice(index, 1);
  res.redirect('/');
});

app.listen(8080, () => {
  console.log('Server is running on port 3000');
});
