

void printTxToReceipt(Transmission tx, boolean isDecode) {
    String flag = isDecode ? "" : "-t";
    Process p = exec("python3", sketchPath() + "/scripts/print_receipt.py", tx.name, 
    Integer.toString(tx.fieldX), Integer.toString(tx.fieldY), Integer.toString(tx.buttonCombo),
    Integer.toString(getAttenuation(tx.txDist)), Integer.toString(getFrequency(tx.txPot)),
    tx.msg);

    try {
        p.waitFor();
        byte[] stdout = new byte[1024];
        byte[] stderr = new byte[1024];
        p.getInputStream().read(stdout);
        p.getErrorStream().read(stderr);
        println("Err: " + new String(stderr));
        println("Out: " + new String(stdout));
    } catch (Exception e) {
        println(e);
    }
}

void loadTxFromCSV() {
    txData = loadTable("resources/transmissions.csv", "header,csv");

    for (TableRow row : txData.rows()) {
        transmissionList.add(new Transmission(row.getString("name"), row.getInt("x"), 
        row.getInt("y"), row.getString("msg"), row.getInt("buttons"), row.getInt("pot"), row.getFloat("dist")));
        transmissionNames.add(row.getString("name"));
    }
}

int getFrequency(int pot) {
    return int(map(pot, 0, 4095, MIN_FREQ, MAX_FREQ));
}

// TODO: ensure this is right
int getAttenuation(float dist) {
    return constrain(int(map(dist, MIN_DIST, MAX_DIST, MAX_ATTEN, MIN_ATTEN)), MIN_ATTEN, MAX_ATTEN);
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