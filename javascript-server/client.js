// Node.js socket client script
const net = require('net');
const prompt = require('prompt-sync')({sigint: true});
var state = 'chatting';

// Connect to a server @ port 9898
const client = net.createConnection({ port: 9898 }, () => {
    console.log('Client connected to the server.');

});
sendMessages();
function isWaitingForRespnse(message){
    return message.endsWith("??") || message.endsWith("bye") || message.endsWith("?");
}
function sendMessages(){
    while(state==='chatting'){
        const message = prompt('You: ');
        console.log('sending...');
        client.write(message);
        if(isWaitingForRespnse(message))
            state='paused';
    }
}

client.on('data', (data) => {
    console.log('Yoda: ' + data.toString());
    if(data.toString()!=='have a nice day!')
        state='chatting';
    sendMessages();
});
//client.on()
client.on('end', () => {
    console.log('Client disconnected from the server.');
});