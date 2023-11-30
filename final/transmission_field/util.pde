

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