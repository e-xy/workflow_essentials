#!/usr/bin/env bash
for i in {0..255}; do
    printf "\x1b[48;5;%sm  \x1b[0m\x1b[38;5;%sm%03d\x1b[0m " "$i" "$i" "$i"
    (( (i + 1) % 6 == 0 )) && echo
done
