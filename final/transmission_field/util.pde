

void printTxToReceipt(Transmission tx) {
    exec("python3", "scripts/print_receipt.py");
}

void loadTxFromCSV() {
    txData = loadTable("resources/transmissions.csv", "header,csv");

    for (TableRow row : txData.rows()) {
        transmissionList.add(new Transmission(row.getString("name"), row.getInt("x"), 
        row.getInt("y"), row.getString("msg"), row.getInt("buttons"), row.getInt("pot"), row.getFloat("dist")));
        transmissionNames.add(row.getString("name"));
    }
}

void writeTxToCSV(Transmission tx) {
    TableRow newEntry = txData.addRow();
    newEntry.setString("name", tx.name);
    newEntry.setInt("x", tx.fieldX);
    newEntry.setInt("y", tx.fieldY);
    newEntry.setInt("buttons", tx.buttonCombo);
    newEntry.setInt("pot", tx.txPot);
    newEntry.setFloat("dist", tx.txDist);
    newEntry.setString("msg", tx.msg);
    
    saveTable(txData, "resources/transmissions.csv");
}

int getTxRadius(String msg) {
    return int(map(msg.length(), 1, 700, 15, 60));
}

int sketchToFieldX(int sketchCoord) {
    return (sketchCoord - (width/2)) + currentCenterX;
}

int sketchToFieldY(int sketchCoord) {
    return (sketchCoord - (height/2)) + currentCenterY;
}

int fieldToSketchX(int fieldCoord) {
    return (width/2) + ((FIELD_WIDTH/2) - fieldCoord);
}

int fieldToSketchY(int fieldCoord) {
    return (height/2) + ((FIELD_HEIGHT/2) - fieldCoord);
}

String getNewTxName() {
    String potentialName = null;

    while (potentialName == null || transmissionNames.contains(potentialName)) {
        potentialName = "TX" + int(random(1000, 9999));
    }

    return potentialName;
}