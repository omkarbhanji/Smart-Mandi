import dotenv from "dotenv";
import pkg from "sequelize";
const { Sequelize } = pkg;

dotenv.config();

const sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect: "postgres",
  logging: false,
});

export default sequelize;
