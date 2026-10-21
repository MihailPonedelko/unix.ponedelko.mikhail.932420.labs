const http = require('node:http');
const amqp = require('amqplib');

async function main() {
    const connection = await amqp.connect('amqp://unix:unix@broker');
    const channel = await connection.createChannel();
    await channel.assertQueue('tasks', { durable: true });

    http.createServer((request, response) => {
        const value = new URL(request.url, 'http://localhost').searchParams.get('n');
        const n = Number(value);
        response.setHeader('Content-Type', 'text/plain; charset=utf-8');
        if (value === null || value.trim() === '' || !Number.isFinite(n)) {
            response.statusCode = 400;
            response.end('Укажите число: /?n=5\n');
            return;
        }
        channel.sendToQueue('tasks', Buffer.from(String(n)), { persistent: true });
        response.end('Задание отправлено\n');
    }).listen(3000, '0.0.0.0');
    console.log('Контроллер запущен на порту 3000');
}

main().catch(error => {
    console.error(error.message);
    process.exit(1);
});
