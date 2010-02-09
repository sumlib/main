#!/usr/bin/python
# -*- coding: utf-8 -*-
# -* encoding utf-8 *-
import pg
import sys
#from Numeric import *

if len(sys.argv)==1:
    print "USAGE: %s <filename> <dbname> [<folder> [<user> <password> <host> <port>]]" 
    sys.exit()
    
    
dane=sys.argv[1] 
db="null"
us="null"
passw="null"
port=5432
host='localhost'
current="."

if len(sys.argv)>2:
    db=sys.argv[2]
if len(sys.argv)>3:
    us=sys.argv[3]
if len(sys.argv)>4:
    passw=sys.argv[4]
if len(sys.argv)>5:
    host=sys.argv[5]
if len(sys.argv)>6:
    port=int(sys.argv[6])
if len(sys.argv)>7:
    current=sys.argv[7]    

 

dane = current + "/../data/" + dane

#ustalenia poczatkowe i funkcje ulatwiajace zapytania + inserty
conn = pg.connect(host=host, user=us, passwd=passw, dbname=db, port=port)


def query(q,a=(),connection=conn):
	#print q % a
	return connection.query(q % a)
	#return cursor # db.use_result()

def fetch(r):
	return r.fetchone()

def insert(q,a=()):
	sys.stderr.write(q % a)
	sys.stderr.write("\n");
	conn.query(q % a)
	#print q % a
	#cr.execute("SELECT id FROM %s WHERE value = %s",a)
	#t = cr.fetchone()
	#cr.close()
	#return t[0].strip() # db_new.use_result()

def insert2(q,a=()):
	print q % a


def napisNull(keyname):
	if keyname=='':
		return "NULL"
	return "'" + keyname + "'"

def findOrAdd(table, keyname):
	if keyname=='':
		return "NULL"
	#escaped_keyname=escape_string(keyname)
	result = query("SELECT id FROM %s WHERE value = '%s'", (table, keyname)).getresult()
	if len(result) == 0:
		insert("INSERT INTO %s(value) VALUES('%s')", (table, keyname))
		result = query("SELECT id FROM %s WHERE value = '%s'", (table, keyname)).getresult()
		return result[0][0]
	else:
		return result[0][0]

	#escaped_keyname=escape_string(keyname)
	#cr = query_new("SELECT id FROM %s WHERE value = %s", (table, escaped_keyname))
	#i = cr.fetchone() 
	#if cr.rowcount==0:
		#print "not found %s: %s, adding" % (table, keyname)
		##if keyname is None :
			##return None
		#return insert("INSERT INTO %d(value) VALUES(%s)", (table, escaped_keyname))
		#print "%s: %s added \n" % (table, keyname)
	#else: 
		#r = i[0].strip()
		#return r
	

def wrzucDane(row):
	#(id_cdli, publikacja, provenience, period, measurements, typ, podtyp, collection, muzeum)
	#row = row[1:-1].strip()
	row = row.split("||")
	id = row[0].strip()[1:].strip()
	insert("INSERT INTO tablet(id, id_cdli, publication, provenience_id, period_id, measurements, genre_id, subgenre_id, collection_id, museum) VALUES(%s, %s, %s,%s, %s, %s,%s, %s, %s, %s);", (id, napisNull(row[0].strip()), napisNull(row[1].strip()), findOrAdd('provenience', row[2].strip()), findOrAdd('period', row[3].strip()), napisNull(row[4].strip()), findOrAdd('genre', row[5].strip()), findOrAdd('genre', row[6].strip()), findOrAdd('collection', row[7].strip()), napisNull(row[8].strip())))
	

f = open(dane,'r')
for line in f:
		wrzucDane(line[:-1].strip())
f.close


# wrzucanie odczytow wygenerowane przez poprawianie/xmltosql.py
#f = open('insert_odczyty.sql','r')
#for line in f:
#		insert(line,())
#f.close
