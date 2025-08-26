const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const userRoutes = require('./routes/userRoutes');
const inventoryRoutes = require('./routes/inventoryRoutes');

app.get('/', (req, res) => {
  res.send('Server is working!');
});

app.use('/api/users', userRoutes);  
app.use('/api/inventory', inventoryRoutes);  

const PORT = 5000;



app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});