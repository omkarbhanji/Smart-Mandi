import Farmer from "./Farmer.js";
import Inventory from "./Inventory.js";
import Market from "./Market.js";
import Sale from "./Sale.js";

Farmer.hasMany(Inventory, {
  foreignKey: "farmerId",
  onDelete: "CASCADE",
});
Inventory.belongsTo(Farmer, {
  foreignKey: "farmerId",
  onDelete: "CASCADE",
});

Inventory.hasMany(Sale, {
  foreignKey: "inventoryId",
  onDelete: "CASCADE",
});
Sale.belongsTo(Inventory, {
  foreignKey: "inventoryId",
  onDelete: "CASCADE",
});

export { Farmer, Inventory, Market, Sale };
