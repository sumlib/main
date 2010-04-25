#!/usr/bin/python
# -*- coding: utf-8 -*-
# -* encoding utf-8 *-
import pg
import sys
#from Numeric import *

if len(sys.argv)==1:
    print "USAGE: %s <dbname> [<folder> [<user> <password> <host> <port>]]" 
    sys.exit()
    
    
db="null"
us="null"
passw="null"
port=5432
host='localhost'
current="."

if len(sys.argv)>1:
    db=sys.argv[1]
if len(sys.argv)>2:
    us=sys.argv[2]
if len(sys.argv)>3:
    passw=sys.argv[3]
if len(sys.argv)>4:
    host=sys.argv[4]
if len(sys.argv)>5:
    port=int(sys.argv[5])
if len(sys.argv)>6:
    current=sys.argv[6]    

 

conn = pg.connect(host=host, user=us, passwd=passw, dbname=db, port=port)

f = open('1-baza_danych/clean.sql','r')
for line in f:
		conn.query(line)
f.close



conn.query()

