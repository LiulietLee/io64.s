#!/bin/bash

# usage: sh make.sh your_source_file.s

FILE="$1"
nasm -f macho64 $1
gcc -fno-pie ${FILE%.*}.o -o ${FILE%.*}
