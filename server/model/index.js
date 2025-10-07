import User from "./User.js";
import Sale from "./Sale.js";
import Market from "./Market.js";
import Inventory from "./Inventory.js";
import FarmerProfile from "./FarmerProfile.js";
import CustomerProfile from "./CustomerProfile.js";

User.hasOne(FarmerProfile, { foreignKey: "userId", as: "farmerProfile" });
FarmerProfile.belongsTo(User, { foreignKey: "userId" });

User.hasOne(CustomerProfile, { foreignKey: "userId", as: "customerProfile" });
CustomerProfile.belongsTo(User, { foreignKey: "userId" });

FarmerProfile.hasMany(Inventory, {
  foreignKey: "farmerId",
  onDelete: "CASCADE",
});
Inventory.belongsTo(FarmerProfile, {
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

export { User, FarmerProfile, CustomerProfile, Inventory, Market, Sale };
