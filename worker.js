const os = require('node:os');
const amqp = require('amqplib');

async function main() {
    const connection = await amqp.connect('amqp://unix:unix@broker');
    const channel = await connection.createChannel();
    await channel.assertQueue('tasks', { durable: true });
    await channel.prefetch(1);

    channel.consume('tasks', message => {
        if (message === null) return;
        const n = Number(message.content.toString());
        setTimeout(() => {
            console.log(`${os.hostname()}: ${n} * ${n} = ${n * n}`);
            channel.ack(message);
        }, 1000);
    });
    console.log('Работник ждёт задания');
}

main().catch(error => {
    console.error(error.message);
    process.exit(1);
});
