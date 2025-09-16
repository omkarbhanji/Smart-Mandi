import { AppError } from "../utils/appError.js";

const sendError = (error, res) => {
  if (error.isOperational) {
    res.status(error.statusCode).json({
      status: error.status,
      message: error.message,
    });
  } else {
    console.log(error.name);
    console.log("Error : " + error);
    res.status(500).json({
      status: "error",
      message: "Something went wrong",
    });
  }
};

const handleSequelizeValidationErrorDB = (err) => {
  const error = Object.create(err.errors).map((e) => e.message);
  const message = `Invalid input data. ${error.join(", ")}`;
  return new AppError(message, 400);
};

const handleSequelizeUniqueConstraintError = (err) => {
  const error = Object.create(err.errors).map((e) => e.message);
  const message = `${error.join(", ")}`;

  return new AppError(message, 400);
};

export const errorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || "error";

  let error = err;

  if (error.name === "SequelizeValidationError") {
    error = handleSequelizeValidationErrorDB(error);
  }

  if (error.name === "SequelizeUniqueConstraintError") {
    error = handleSequelizeUniqueConstraintError(error);
  }

  sendError(error, res);
};
