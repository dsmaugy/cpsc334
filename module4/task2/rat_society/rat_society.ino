#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <Stepper.h>
#include <ESP32Servo.h>
#include "WiFi.h"
#include "secrets.h"


// FOLLOWING SECRETS DEFINED IN secrets.ino
// #define API_KEY
// #define SSID
// #define WIFI_PASS

#define STOCK_API_FORMAT "https://api.polygon.io/v2/aggs/ticker/%s/prev?apiKey=%s"
#define TEST_JSON "{\"ticker\":\"AAPL\",\"queryCount\":1,\"resultsCount\":1,\"adjusted\":true,\"results\":[{\"T\":\"AAPL\",\"v\":7.9829246e+07,\"vw\":175.5751,\"o\":174.24,\"c\":176.65,\"h\":176.82,\"l\":173.35,\"t\":1699041600000,\"n\":858038}],\"status\":\"OK\",\"request_id\":\"509cb86f6d68ea6eff37a002f144438b\",\"count\":1}"

// Motor/Servo Definitions
#define IN1 19
#define IN2 18
#define IN3 5
#define IN4 17
#define SERVO 26
#define stepsPerRevolution 2048

Stepper spinner(stepsPerRevolution, IN1, IN3, IN2, IN4);
int spinnerSpeed = 10;

char apiEndpoint[256];
StaticJsonDocument<512> responseJson;

WiFiServer server(8888);

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

  server.begin();
  Serial.println(getStockChange("AAPL"));
}

void loop(){
  spinner.setSpeed(spinnerSpeed);
  WiFiClient client = server.available();
  
  if (client) {
    while (client.connected()) {
      if (client.available()) {
        String controllerReq = client.readStringUntil("\n");
      }
    }
  }
  // Serial.println(apiEndpoint);
}

float getStockChange(char* tickerVal) {
  HTTPClient http;
  sprintf(apiEndpoint, STOCK_API_FORMAT, tickerVal, API_KEY);
  http.begin(apiEndpoint);
  // int requestStatus = http.GET();
  int requestStatus = 5;
  if (requestStatus > 0) {
    // String payload = http.getString();
    String payload = TEST_JSON;
    Serial.println(payload);
    DeserializationError err = deserializeJson(responseJson, payload);
    if (err) {
      return 0.0;
    } else {
      double open = responseJson["results"][0]["o"];
      double close = responseJson["results"][0]["c"];
      return close - open;
    }
  }

  return 0.0;
}