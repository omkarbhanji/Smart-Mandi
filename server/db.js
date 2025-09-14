import dotenv from 'dotenv';
import pkg from 'sequelize';
const { Sequelize } = pkg;


dotenv.config();

const sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect: 'postgres',
  logging: false,
});

sequelize.sync({ alter: true }) 
  .then(() => console.log("Database synced"))
  .catch(err => console.error("Sync error:", err));

if(!sequelize){
  console.log("DB connection failure");
}

export default sequelize;