# Лабораторная №4. Горизонтально масштабируемый сервис

Сервис вычисляет квадрат числа. `controller` получает число по HTTP и отправляет его в RabbitMQ. Несколько контейнеров `worker` берут задания из общей очереди. `prefetch(1)` выдаёт работнику по одному заданию, `ack` подтверждает выполнение. Результаты выводятся в журнал с именем контейнера.

Запуск в Ubuntu из этой папки при работающем Docker Desktop:

```sh
docker compose up -d --build --scale worker=3
```

Отправка одного задания:

```sh
curl 'http://localhost:3000/?n=5'
docker compose logs worker
```

В ответе будет `Задание отправлено`, в журнале одного из работников: `имя-контейнера: 5 * 5 = 25`.

Проверка распределения заданий:

```sh
for n in 1 2 3 4 5 6 7 8 9; do
    curl "http://localhost:3000/?n=$n"
done
sleep 4
docker compose logs worker
```

Имена контейнеров в журнале должны различаться. Задержка в одну секунду в `worker.js` имитирует обработку задания.

Изменить число работников и остановить сервис:

```sh
docker compose up -d --scale worker=5
docker compose down
```

[Задание](https://marigostra.ru/materials/unix.html), [пример очереди работников RabbitMQ](https://www.rabbitmq.com/tutorials/tutorial-two-javascript).
