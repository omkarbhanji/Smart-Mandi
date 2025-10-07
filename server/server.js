import dotenv from "dotenv";
import app from "./app.js";
import sequelize from "./db.js";

dotenv.config();

sequelize
  .sync({ alter: true })
  .then(() => console.log("Database connected successfully"))
  .catch((err) =>
    console.error("Error while connecting to db", err.name, err.message)
  );

const port = process.env.PORT;

app.listen(port, "0.0.0.0", () => {
  console.log(`Server running on http://0.0.0.0:${port}`);
});
