// const { DataTypes } = require("sequelize");
import { DataTypes } from "sequelize";
import sequelize from "../db.js"; 

const Farmer = sequelize.define("Farmer", {
  farmerId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  email: {
    type: DataTypes.STRING(150),
    allowNull: false,
    unique: true,
  },
  password: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  phone: {
    type: DataTypes.STRING(15),
    unique: true,
  },
  location: {
    type: DataTypes.STRING(255),
  },
  state: {
    type: DataTypes.STRING(100),
  },
  createdAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  updatedAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  latitude: {
    type: DataTypes.DECIMAL(9, 6),
  },
  longitude: {
    type: DataTypes.DECIMAL(9, 6),
  },
}, {
  tableName: "farmers", 
  timestamps: false,    
});

export default Farmer;
