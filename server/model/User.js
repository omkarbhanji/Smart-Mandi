import sequelize from "../db.js";
import { DataTypes } from "sequelize";
import bcrypt from "bcrypt";

const User = sequelize.define(
  "User",
  {
    userId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING(100),
      allowNull: false,
      validate: {
        notEmpty: {
          msg: "name cannot be empty.",
        },
        len: {
          args: [3, 20],
          msg: "name must be between 3 and 20 characters",
        },
      },
    },
    email: {
      type: DataTypes.STRING(150),
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    password: {
      type: DataTypes.STRING(255),
      allowNull: false,
      validate: {
        notEmpty: {
          msg: "password cannot be empty",
        },
        len: {
          args: [8, 100],
          msg: "password must be at least 8 characters long",
        },
      },
    },
    phone: {
      type: DataTypes.STRING(15),
      allowNull: false,
      unique: true,
      validate: {
        len: {
          args: [10],
          msg: "phone number must contain 10 digits",
        },
      },
    },
    role: {
      type: DataTypes.ENUM("farmer", "customer"),
      allowNull: false,
    },
  },
  {
    tableName: "Users",
    timestamps: false,
    defaultScope: {
      attributes: { exclude: ["password"] },
    },
    hooks: {
      beforeCreate: async (user) => {
        if (user.password) {
          user.password = await bcrypt.hash(user.password, 5);
        }
      },
    },
  }
);

export default User;
