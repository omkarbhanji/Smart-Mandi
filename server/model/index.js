import User from "./User.js";
import Sale from "./Sale.js";
import Market from "./Market.js";
import Inventory from "./Inventory.js";
import FarmerProfile from "./FarmerProfile.js";
import CustomerProfile from "./CustomerProfile.js";
import BuyRequest from "./buyRequest.js";

// User ↔ FarmerProfile (One-to-One)
User.hasOne(FarmerProfile, { foreignKey: "userId", as: "farmerProfile" });
FarmerProfile.belongsTo(User, { foreignKey: "userId" });

// User ↔ CustomerProfile (One-to-One)
User.hasOne(CustomerProfile, { foreignKey: "userId", as: "customerProfile" });
CustomerProfile.belongsTo(User, { foreignKey: "userId" });

// FarmerProfile ↔ Inventory (One-to-Many)
User.hasMany(Inventory, {
  foreignKey: "farmerId",
  onDelete: "CASCADE",
});
Inventory.belongsTo(User, {
  foreignKey: "farmerId",
  as: "farmer",
  onDelete: "CASCADE",
});

// Inventory ↔ Sale (One-to-Many)
Inventory.hasMany(Sale, {
  foreignKey: "inventoryId",
  onDelete: "CASCADE",
});
Sale.belongsTo(Inventory, {
  foreignKey: "inventoryId",
  onDelete: "CASCADE",
});

// User ↔ BuyRequest (Customer & Farmer roles)
User.hasMany(BuyRequest, {
  foreignKey: "customerId",
  as: "customerRequests",
  onDelete: "CASCADE",
});
User.hasMany(BuyRequest, {
  foreignKey: "farmerId",
  as: "farmerRequests",
  onDelete: "CASCADE",
});

// BuyRequest ↔ User (both sides)
BuyRequest.belongsTo(User, {
  foreignKey: "customerId",
  as: "customer",
});
BuyRequest.belongsTo(User, {
  foreignKey: "farmerId",
  as: "farmer",
});

// Inventory ↔ BuyRequest (One-to-Many)
Inventory.hasMany(BuyRequest, {
  foreignKey: "inventoryId",
  onDelete: "CASCADE",
});
BuyRequest.belongsTo(Inventory, { foreignKey: "inventoryId", as: "inventory" });

export {
  User,
  FarmerProfile,
  CustomerProfile,
  Inventory,
  Market,
  Sale,
  BuyRequest,
};
