

void printTxToReceipt(Transmission tx) {
    // TODO use exec here to call python program
}

void loadTxFromCSV() {
    txData = loadTable("resources/transmissions.csv", "header,csv");

    for (TableRow row : txData.rows()) {
        transmissionList.add(new Transmission(row.getString("name"), row.getInt("x"), 
        row.getInt("y"), row.getString("msg"), row.getInt("buttons"), row.getInt("pot"), row.getFloat("dist")));
    }
}

void uploadTx(String message, int xCoord, int yCoord, int buttons, int dist, int pot) {
    // TODO: save new Transmission object to transmission list and write to CSV
}

int getTxRadius(String msg) {
    return int(map(msg.length(), 1, 700, 15, 60));
}

int sketchToFieldX(int sketchCoord) {

}

int sketchToFieldY(int sketchCoord) {

}

int fieldToSketchX(int fieldCoord) {

}

int fieldToSketchY(int fieldCoord) {
    
}