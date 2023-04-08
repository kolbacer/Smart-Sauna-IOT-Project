const express = require('express')
const bodyParser = require('body-parser')
const {broker} = require('../broker/broker')

const app = express()
const port = process.env.PORT

const jsonParser = bodyParser.json()

const subscriptions = {
    monitoringValue: null,
    currentConfig:null
}

//Subscriptions
broker.on('connect', function () {

    console.log('connected')
    broker.subscribe(['device/monitoring','device/getconfigreply'], function (err) {
        if (err) {
            console.log('Error  ' + err)
        }else if(!err){
            console.log('Fine  ' + err)
        }
    })
})

broker.on('message', function(topic,message){
    if(topic === "device/monitoring"){
        subscriptions.monitoringValue = message.toString()
        // console.log('Monitoring  ' + message.toString())
    }
    if(topic === 'device/getconfigreply'){
        subscriptions.currentConfig = message
        // console.log('Current config  ' + message)
    }
})

app.get('/getconfig', async (req, res) => {
    try {
        broker.publish('server/getconfigcommand',"get")
        const wait = new Promise((resolve, reject) => {
                setTimeout(() => {
                resolve(res.send(subscriptions.currentConfig))},300)})
        await wait
    }catch (err){
        console.log(err)
        res.status(500).send('ERROR: ' + err)
    }
})

app.get('/monitoring', (req, res) => {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Acces-Control-Allow-Origin','*');

    try {
        const intervalId = setInterval(()=>{
            console.log('Get current config ' + subscriptions.monitoringValue)
            res.write(`data: ${subscriptions.monitoringValue}\n\n`)
        },5000)

        res.on('close', () => {
            console.log('Client closed connection')
            clearInterval(intervalId)
            res.end()
        })
    }catch (err){
        console.log(err)
        res.status(500).send('ERROR: ' + err)
    }
})

app.post('/setconfig', jsonParser, (req,res) => {
    try {
        broker.publish('server/setconfig', JSON.stringify({heater: req.body.heater, targetTmp: req.body.targetTmp, delta: req.body.delta}))
        res.send('New config published')
    }catch (err){
        console.log(err)
        res.status(500).send('ERROR: ' + err)
    }
})

app.listen(port, () => {
    console.log(`Listening on port ${port}`)
})