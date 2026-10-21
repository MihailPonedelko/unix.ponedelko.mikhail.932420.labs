# Лабораторная №3. Жёсткие ссылки

Программа обходит каталог с подкаталогами, считает SHA-256 через OpenSSL и заменяет файлы с одинаковым хэшем жёсткими ссылками. Символьные ссылки пропускаются. Внешние программы из кода не вызываются.

Сборка и запуск в Ubuntu:

```sh
g++ -std=c++17 -Wall -Wextra main.cpp -o duplicates -lcrypto
./duplicates /путь/к/каталогу
```

Для проверки можно создать два одинаковых файла:

```sh
mkdir -p /tmp/lab03-example/sub
printf 'hello\n' > /tmp/lab03-example/a.txt
cp /tmp/lab03-example/a.txt /tmp/lab03-example/sub/b.txt
./duplicates /tmp/lab03-example
ls -li /tmp/lab03-example/a.txt /tmp/lab03-example/sub/b.txt
```

После запуска у файлов одинаковый inode и число ссылок 2. Каталог должен находиться в одной файловой системе. Для проверки в WSL удобно использовать `/tmp`.

[Задание](https://marigostra.ru/materials/unix.html)
