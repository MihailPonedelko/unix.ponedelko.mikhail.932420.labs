#!/bin/sh

if [ "$#" -eq 0 ]; then
    echo "Usage: sh build.sh main.c [other.c ...]" >&2
    exit 1
fi

for source in "$@"; do
    if [ ! -f "$source" ] || [ ! -r "$source" ]; then
        echo "Cannot read: $source" >&2
        exit 1
    fi
done

directory=$(cd -- "$(dirname -- "$1")" && pwd) || exit 1
output=$(sed -n 's|^[[:space:]]*//[[:space:]]*Output:[[:space:]]*\([^[:space:]]*\)[[:space:]]*$|\1|p' "$1" | head -n 1)
case "$output" in
    ''|.|..|*/*|-*)
        echo "Invalid or missing Output comment" >&2
        exit 2
        ;;
esac
for source in "$@"; do
    if [ "$output" = "$(basename -- "$source")" ]; then
        echo "Output must differ from the source name" >&2
        exit 2
    fi
done

temporary=
compiler=
cleanup() {
    if [ -n "$compiler" ]; then
        kill "$compiler" 2>/dev/null
        wait "$compiler" 2>/dev/null
    fi
    if [ -n "$temporary" ]; then
        rm -rf -- "$temporary"
    fi
}
trap cleanup 0
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 131' QUIT
trap 'exit 141' PIPE
trap 'exit 143' TERM

temporary=$(mktemp -d) || exit 4
cp -- "$@" "$temporary/" || exit 4
cd -- "$temporary" || exit 4
gcc -Wall -Wextra ./*.c -o "$output" &
compiler=$!
wait "$compiler"
status=$?
compiler=
if [ "$status" -ne 0 ]; then
    echo "Compilation failed" >&2
    exit 3
fi
mv -- "$output" "$directory/$output" || exit 4
