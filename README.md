# Лабораторная №2. Конкурентный контейнер

Контейнер создаёт файл в общем томе, через секунду удаляет его и ещё через секунду повторяет цикл. Имя — первое свободное из `001`, `002`, `003` и далее. В файле записаны случайный идентификатор контейнера и его счётчик созданных файлов. Выбор имени, запись и удаление выполняются под `flock` через общий файл `.lock`.

В терминале Ubuntu из папки лабораторной:

```sh
docker compose -p unix-lab02 up -d --build --scale worker=1
```

Для десяти и пятидесяти экземпляров:

```sh
docker compose -p unix-lab02 up -d --scale worker=10
docker compose -p unix-lab02 up -d --scale worker=50
```

Посмотреть файлы и содержимое:

```sh
docker compose -p unix-lab02 exec --index 1 worker sh -c 'ls -a /shared; cat /shared/[0-9]* 2>/dev/null'
```

Остановка:

```sh
docker compose -p unix-lab02 down
```

[Задание](https://marigostra.ru/materials/unix.html), [практика по Shell: циклы, trap и flock](https://marigostra.ru/materials/presentation-unix-lab01.pdf).
