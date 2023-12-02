

void printTxToReceipt(Transmission tx) {
    // TODO use exec here to call python program
}

void loadTxFromCSV() {
    txData = loadTable("resources/transmissions.csv", "header,csv");

    for (TableRow row : txData.rows()) {
        transmissionList.add(new Transmission(row.getString("name"), row.getInt("x"), 
        row.getInt("y"), int(map(row.getString("msg").length(), 1, 700, 30, 90))));
    }
}

void uploadTx(String message, int xCoord, int yCoord, int buttons, int dist, int pot) {
    // TODO: save new Transmission object to transmission list and write to CSV
}

void serialEvent(Serial p) {
    String e = p.readString();
    if (e.startsWith("DIST:")) {
        distVal = int(e.substring(5, e.length()-1));
    } else if (e.startsWith("POT:")) {
        potVal = int(e.substring(4, e.length()-1));
    }
}