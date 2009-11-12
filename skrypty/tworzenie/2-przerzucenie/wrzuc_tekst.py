#!/usr/bin/python
# -*- coding: utf-8 -*-
# -* encoding utf-8 *-
#import pg
import psycopg
import sys
#from Numeric import *

if len(sys.argv)==1:
    print "USAGE: %s <filename> <dbname> [<folder> [<user> <password>]]" 
    sys.exit()
    
    
dane=sys.argv[1]
db="sumlib"
us="asia"
passw="achajka"
current="."

if len(sys.argv)>2:
    db=sys.argv[2]
if len(sys.argv)>3:
    current=sys.argv[3]
if len(sys.argv)>4:
    us=sys.argv[4]
if len(sys.argv)>5:
    passw=sys.argv[5]

    
  

dane = current + "/../data/" + dane

#ustalenia poczatkowe i funkcje ulatwiajace zapytania + inserty
conn = psycopg.connect('host=localhost user=%s password=%s dbname=%s' % (us, passw, db)) # odkomentowac!!!
cur = conn.cursor()



def update(q,a=()):
	#sys.stderr.write(q % a)
	#sys.stderr.write("\n");
	cur.execute(q,a)
#	conn.query(q,a)         # odkomentowac!!!


def update2(q,a=()):
	print q % a


def napisNull(keyname):
	if keyname=='':
		return None
	return keyname
	

def zapisz_tabliczke_do_bazy(id_tabliczki,tekst):
	print id_tabliczki
	update("""UPDATE tabliczka SET tekst = %s WHERE id_cdli=%s;""", (napisNull(tekst), id_tabliczki))
	

f = open(dane,'r')
show = ""
id_tabliczki = "0"
for line in f:
	if (line[0] == '&'):
		if (id_tabliczki != "0" and id_tabliczki != ""):
			zapisz_tabliczke_do_bazy(id_tabliczki,show)
		id_tabliczki = line[1:8]
		show = ""
	elif (line[0] == '#'):
		x=0 #nic
	else:
		show = show + line

if (id_tabliczki != "0" and id_tabliczki != ""):
	zapisz_tabliczke_do_bazy(id_tabliczki,show)

conn.commit()
cur.close()

f.close


