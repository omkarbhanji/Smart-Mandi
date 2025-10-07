import { DataTypes } from "sequelize";
import sequelize from "../db.js";
import User from "./User.js";

const FarmerProfile = sequelize.define("FarmerProfile", {
  farmerId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: User,
      key: "userId",
    },
  },

  location: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  state: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  latitude: {
    type: DataTypes.DECIMAL(9, 6),
    allowNull: false,
  },
  longitude: {
    type: DataTypes.DECIMAL(9, 6),
    allowNull: false,
  },
});

export default FarmerProfile;
