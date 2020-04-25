#!/bin/bash
#arecord -f S16_LE -t raw -c 2 -r 16000 -d 5 test.wav
arecord -v -f S16_LE -t raw -r 16000 -d 5 | lame -r -b 16 --scale - test.wav
