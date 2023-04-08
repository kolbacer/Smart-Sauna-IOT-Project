#include "DHT.h" // DHT sensor library by Adafruit
#include <ArduinoJson.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h>

#define TMP36_PIN A0
#define DHT11_PIN 14
#define BLUE_LED_PIN 16
#define YELLOW_LED_PIN 5

const char* ssid = "DIR-632";
const char* password = "76543210";
const char* mqtt_server = "192.168.0.27";

WiFiClient espClient;
PubSubClient client(espClient);
unsigned long lastMsg = 0;
#define MSG_BUFFER_SIZE	(200)
char msg[MSG_BUFFER_SIZE];

DHT dht(DHT11_PIN, DHT11);

struct Settings {
  float targetTmp; // target temperature
  float delta;     // thermostat hysteresis

  float getMin() {
    return targetTmp - delta/2;
  }

  float getMax() {
    return targetTmp + delta/2;
  }
};

Settings saunaSettings;
Settings poolSettings;
bool isSaunaHeating = false;
bool isPoolHeating = false;

void setup_wifi() {

  delay(10);
  // Start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* payload, unsigned int length) {

  char jsonStr[length + 1];
  memcpy(jsonStr, payload, length);
  jsonStr[length] = 0; // Null termination.

  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  Serial.println(jsonStr);

  StaticJsonDocument<200> jsonDoc;

  if (strcmp(topic,"server/setconfig")==0){

    auto error = deserializeJson(jsonDoc, jsonStr);
    if (error) {
      Serial.print(F("deserializeJson() failed with code "));
      Serial.println(error.c_str());
      return;
    }

    String heater = jsonDoc["heater"];
    float targetTmp = jsonDoc["targetTmp"];
    float delta = jsonDoc["delta"];

    if (heater == "sauna") {
      saunaSettings.targetTmp = targetTmp;
      saunaSettings.delta = delta;
    } else if (heater == "pool") {
      poolSettings.targetTmp = targetTmp;
      poolSettings.delta = delta;
    }

  }

  if (strcmp(topic,"server/getconfigcommand")==0){

    snprintf (msg, MSG_BUFFER_SIZE, "[{\"heater\": \"sauna\", \"targetTmp\": %f, \"delta\": %f},"
                                    "{\"heater\": \"pool\", \"targetTmp\": %f, \"delta\": %f}]",
                                    saunaSettings.targetTmp, saunaSettings.delta,
                                    poolSettings.targetTmp, poolSettings.delta);
    Serial.print("Publish message: ");
    Serial.println(msg);
    client.publish("device/getconfigreply", msg);
  }
}

void reconnect() {
  // Loop until reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random client ID
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);
    // Attempt to connect
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
      // subscribe to topics
      client.subscribe("server/setconfig");
      client.subscribe("server/getconfigcommand");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void setup()
{
  Serial.begin(115200);

  pinMode(YELLOW_LED_PIN, OUTPUT);
  pinMode(BLUE_LED_PIN, OUTPUT);

  pinMode(DHT11_PIN, INPUT);
  dht.begin();

  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  saunaSettings = {30, 1};
  poolSettings = {35, 2};
}

void loop()
{
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  unsigned long now = millis();
  if (now - lastMsg > 1000) {
    lastMsg = now;

    float saunaTmp = dht.readTemperature();
    float saunaHum = dht.readHumidity();
    float poolTmp = getTmp(analogRead(TMP36_PIN));

    // check sauna
    if (!isSaunaHeating && (saunaTmp < saunaSettings.getMin())) {
      // turn on thermostat
      digitalWrite(YELLOW_LED_PIN, HIGH);
      isSaunaHeating = true;
    }
    else if (isSaunaHeating && (saunaTmp > saunaSettings.getMax())) {
      // turn off thermostat
      digitalWrite(YELLOW_LED_PIN, LOW);
      isSaunaHeating = false;
    }

    // check pool
    if (!isPoolHeating && (poolTmp < poolSettings.getMin())) {
      // turn on thermostat
      digitalWrite(BLUE_LED_PIN, HIGH);
      isPoolHeating = true;
    }
    else if (isPoolHeating && (poolTmp > poolSettings.getMax())) {
      // turn off thermostat
      digitalWrite(BLUE_LED_PIN, LOW);
      isPoolHeating = false;
    }

    // Send MQTT message
    snprintf (msg, MSG_BUFFER_SIZE, "{\"saunaTmp\": %f, \"saunaHum\": %f, \"poolTmp\": %f}", saunaTmp, saunaHum, poolTmp);
    Serial.print("Publish message: ");
    Serial.println(msg);
    client.publish("device/monitoring", msg);
  }
}

float getTmp(int reading) {
  // Convert the reading into voltage:
  float voltage = reading * (3300 / 1024.0);

  // Convert the voltage into the temperature in Celsius:
  return (voltage - 500) / 10;
}