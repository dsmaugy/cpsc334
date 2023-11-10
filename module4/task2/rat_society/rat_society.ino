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

// Hardware Definitions
#define IN1 19
#define IN2 18
#define IN3 5
#define IN4 17
#define stepsPerRevolution 2048
#define KNIFE_UP 0
#define KNIFE_DOWN 20
#define KNIFE_DURATION 100

/*
WARNING, CANNOT USE ADC PINS:
GPIO4, GPIO0, GPIO2, GPIO15, GPIO13, GPIO12, GPIO14, GPIO27, GPIO25 and GPIO26
WHEN WIFI IS ENABLED!!!
*/
#define PHOTO 34
#define SERVO 23

Servo knife;
long last_knife_transition;
bool knife_down;
int knife_cooldown;

Stepper spinner(stepsPerRevolution, IN1, IN3, IN2, IN4);
int spinnerSpeed = 10;

char apiEndpoint[256];
StaticJsonDocument<512> responseJson;

WiFiServer server(8888);

String currentStock;
float stockDeltaPct = 0;
bool cfpb_funded = false;

void setup(){

  Serial.begin(9600);
  Serial.println("Serial start");
  WiFi.mode(WIFI_STA);
  WiFi.begin(SSID, WIFI_PASS);

  pinMode(PHOTO, INPUT);
  knife.attach(SERVO);

  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
  }
  Serial.println();
  Serial.println(WiFi.localIP());

  knife.write(KNIFE_UP);
  knife_down = false;
  last_knife_transition = millis();
  knife_cooldown = 100;
  
  server.begin();
  // Serial.println(getStockChange("AAPL"));
  // currentStock = "CAKE";
  // stockDeltaPct = getStockChange(currentStock.c_str());
}

void loop(){
  WiFiClient client = server.available();
  
  if (client) {
    while (client.connected()) {
      if (client.available()) {
        String controllerReq = client.readStringUntil('\n');
        Serial.println("New Message: " + controllerReq);

        if (controllerReq.equals("FUND")) {
          cfpb_funded = true;
          Serial.println("CFPB Funded");
        } else if (controllerReq.equals("DEFUND")) {
          Serial.println("CFPB Defunded");
          cfpb_funded = false;
        } else if (controllerReq.startsWith("STOCK")) {
          currentStock = controllerReq.substring(6);
          stockDeltaPct = getStockChange(currentStock.c_str());
          Serial.printf("New STOCK Delta: %f\n", stockDeltaPct);
        }
      }

      actuatorControl();
    }
  } else {
    actuatorControl();
  }

}

void actuatorControl() {
  // Serial.println(analogRead(PHOTO));
  // Serial.println(knife.read());
  int light = analogRead(PHOTO);
  if (light > 100) {
    spinner.setSpeed(map(light, 100, 4095, 4, 12));
    spinner.step(8);

    if (!cfpb_funded && stockDeltaPct < 0) {
      if (knife_down && millis() - last_knife_transition > KNIFE_DURATION) {
        swing_knife_up();
      } else if (!knife_down && millis() - last_knife_transition > knife_cooldown) {
        swing_knife_down();
        int cooldown_range = max((int) map(stockDeltaPct*100, -60, 0, 20, 500), 20);
        knife_cooldown = random(cooldown_range, cooldown_range + 50);
        Serial.printf("New Cooldown: %d\n", knife_cooldown);
      }
    } else {
      swing_knife_up();
    }
  }
}

void swing_knife_down() {
  knife.write(KNIFE_DOWN);
  knife_down = true;
  last_knife_transition = millis();
}

void swing_knife_up() {
  knife.write(KNIFE_UP);
  knife_down = false;
  last_knife_transition = millis();
}

float getStockChange(const char* tickerVal) {
  HTTPClient http;
  sprintf(apiEndpoint, STOCK_API_FORMAT, tickerVal, API_KEY);
  http.begin(apiEndpoint);
  int requestStatus = http.GET();
  // int requestStatus = 5;
  if (requestStatus > 0) {
    String payload = http.getString();
    // String payload = TEST_JSON;
    Serial.println(payload);
    DeserializationError err = deserializeJson(responseJson, payload);
    if (err) {
      return 0.0;
    } else if (responseJson["resultsCount"] > 0){
      double open = responseJson["results"][0]["o"];
      double close = responseJson["results"][0]["c"];
      return (close - open)/open;
    }
  }

  return 0.0;
}