exports.addInInventory = async (req, res) => {
    const farmerId = req.body.id; // for now it is taken from json, later it will be taken from json token
    const cropName = req.body.cropName;
    const quantity = req.body.quantity;
    const unit = req.body.unit;
    const harvestDate = req.body.harvestDate;
    // const expiryDate = harvestDate + (time taken for that veg to rot)
    // const remainingQuantity = req.body.quantity; // initially same as quantity, further will be updated directly by sales function
    // const status = initially available Later can be updated as -> (available, sold out, expired)
    
    

};