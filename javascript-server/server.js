//console.log("hello");
// Node.js socket server script
const net = require('net');
const answers = ['yes','no','sure','idk','maybe','ask me later'];
const wisdom = ['Do or do not. There is no try.','You must unlearn what you have learned.','Named must be your fear before banish it you can.','Fear is the path to the dark side.','The greatest teacher, failure is.'];

var randomChoise = 2;
// Create a server object
const server = net.createServer((socket) => {
    socket.on('data', (data) => {
        console.log('user: ' + data.toString());
        if(data.toString().endsWith("??")){
            randomChoise = Math.floor(Math.random() * 5);
            socket.write(wisdom[randomChoise]);
            console.log('server: ' + wisdom[randomChoise]);
        }else if(data.toString().endsWith("?")){
            randomChoise = Math.floor(Math.random() * 6);
            socket.write(answers[randomChoise]);
            console.log('server: ' + answers[randomChoise]);
        }else if(data.toString().endsWith("bye")){
            socket.write('have a nice day!');
            console.log('server: ' + 'have a nice day!');
            socket.end();
        }
    });
}).on('error', (err) => {
    console.error(err);
});
// Open server on port 9898
server.listen(9898, () => {
    console.log('opened server on', server.address().port);
});