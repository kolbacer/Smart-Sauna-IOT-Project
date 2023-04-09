const express = require('express')
const bodyParser = require('body-parser')
const {broker} = require('./broker')

const app = express()
const port = process.env.PORT

const jsonParser = bodyParser.json()

//Subscriptions
broker.on('connect', function () {
    console.log('MQTT connected')

    broker.subscribe(['device/monitoring','device/getconfigreply'], function (err) {
        if (err) {
            console.log('Topics subscription error: ' + err)
        } else {
            console.log('Topics subscription success')
        }
    })
})

//Callbacks
let monitoringCallbackProps = {
    ignore: true,
    res: null
}
let monitoringCallback = (msg) => {
    let props = monitoringCallbackProps
    if (props.ignore) return

    try {
        props.res.write(`data: ${msg.toString()}\n\n`)
    } catch (err) {
        console.log(err)
        props.res.status(500).send('ERROR: ' + err)
    }
}

let getconfigreplyCallbackProps = {
    ignore: true,
    res: null,
    replyReceived: null
}
let getconfigreplyCallback = (msg) => {
    let props = getconfigreplyCallbackProps
    if (props.ignore) return

    try {
        props.res.send(msg)
    } catch (err){
        console.log(err)
        props.res.status(500).send('ERROR: ' + err)
    }

    props.replyReceived()
}

broker.on('message', function(topic,message){
    if(topic === "device/monitoring"){
        console.log('Received message from device/monitoring')
        monitoringCallback(message)
    }
    if(topic === 'device/getconfigreply'){
        console.log('Received message from device/getconfigreply')
        getconfigreplyCallback(message)
    }
})

//API
app.get('/getconfig', async (req, res) => {

    getconfigreplyCallbackProps.res = res
    const waitReply = new Promise((resolve, reject) => {
        getconfigreplyCallbackProps.replyReceived = resolve
    })
    getconfigreplyCallbackProps.ignore = false

    broker.publish('server/getconfigcommand',"get")

    await waitReply
    getconfigreplyCallbackProps.ignore = true
    getconfigreplyCallbackProps.res = null
    getconfigreplyCallbackProps.replyReceived = null
})

app.get('/monitoring', (req, res) => {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Acces-Control-Allow-Origin','*');

    monitoringCallbackProps.res = res
    monitoringCallbackProps.ignore = false

    res.on('close', () => {
        console.log('Client closed connection')
        monitoringCallbackProps.ignore = true
        monitoringCallbackProps.res = null
        res.end()
    })
})

app.post('/setconfig', jsonParser, (req,res) => {
    try {
        broker.publish('server/setconfig', JSON.stringify({
            heater: req.body.heater,
            targetTmp: req.body.targetTmp,
            delta: req.body.delta}))
        res.send('New config published')
    } catch (err){
        console.log(err)
        res.status(500).send('ERROR: ' + err)
    }
})

app.listen(port, () => {
    console.log(`Listening on port ${port}`)
})