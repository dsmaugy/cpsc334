#include "WiFi.h"
#include <HTTPClient.h>
#include "secrets.h"

// FOLLOWING SECRETS DEFINED IN secrets.ino
// API_KEY
// SSID
// WIFI_PASS

#define STOCK_API_FORMAT "https://api.polygon.io/v2/aggs/ticker/%s/prev?apiKey=%s"

void setup(){

  Serial.begin(9600);
  WiFi.mode(WIFI_STA);
  WiFi.begin(SSID, WIFI_PASS);

  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
  }
  Serial.println();
  Serial.println(WiFi.localIP());

}

void loop(){
  char apiEndpoint[256];
  sprintf(apiEndpoint, STOCK_API_FORMAT, "AAPL", API_KEY);

  Serial.println(apiEndpoint);
}