#!/bin/sh
set -e

cd /shared
id=$(cat /proc/sys/kernel/random/uuid)
count=0
file=
exec 9>.lock

cleanup() {
    if [ -n "$file" ]; then
        flock 9
        rm -f -- "$file"
    fi
}

trap cleanup 0
trap 'exit 1' HUP INT QUIT TERM

while true; do
    count=$((count + 1))
    flock 9
    n=1
    name=$(printf '%03d' "$n")
    while [ -e "$name" ]; do
        n=$((n + 1))
        name=$(printf '%03d' "$n")
    done
    file=$name
    printf '%s %s\n' "$id" "$count" > "$file"
    flock -u 9

    sleep 1

    flock 9
    rm -- "$file"
    file=
    flock -u 9

    sleep 1
done
