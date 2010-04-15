#!/bin/bash

g++ -g -W -Wall -c test.cpp &&  (g++ -g -W -Wall test.o -o test -lzorba && echo; echo; ./test)