const mqtt = require('mqtt')

//Connect to mqtt_server
const client = mqtt.connect(process.env.MQTT_SERVER)

module.exports.broker = client;

