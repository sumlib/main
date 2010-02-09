# -*- coding: utf-8 -*-
from xml.dom import minidom
import sys
import re
import psycopg2
import cgi


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
    port=sys.argv[6]
if len(sys.argv)>7:
    current=sys.argv[7]    

dane = current + "/../data/" + dane

#ustalenia poczatkowe i funkcje ulatwiajace zapytania + inserty
conn = psycopg2.connect('host=%s user=%s password=%s dbname=%s port=%s' % (host, us, passw, db, port))
cur = conn.cursor()


def insert(q,a=()):
	#sys.stderr.write(q % a)
	#sys.stderr.write("\n");
	cur.execute(q,a)
	#conn.query(q % a)
	#print q % a
	#cr.execute("SELECT id FROM %s WHERE wartosc = %s",a)
	#t = cr.fetchone()
	#cr.close()
	#return t[0].strip() # db_new.use_result()

def insert2(q,a=()):
	print q % a


def napisNull(keyname):
	if keyname=='':
		return None
	return keyname

def struktura_tabliczki(slowo):
	if (slowo[0] == '@'): return 1
	return 0

def numer_linii(slowo):
	i = len(slowo)
	if (slowo[i-1] == '.'):
		return 1
	return 0
	
	
def sprawdz_linie(linia):
	#sprawdza czy nawiasy kwadratowe pasuja do siebie (bez zagniezdzania)
	pasuje = re.match(r'([^][]*\[[^][]*\])*[^][]*$',linia)
	if (pasuje):
		return 0
	else:
		return 1

def filtruj(linia):
	
	if (sprawdz_linie(linia) == 1):
		return None

	slowa = linia.split(); #wersja demo
	retVal = [0 for row in range (len(slowa))]
	bylo = 0
	i = 0

	for sl in slowa:
		if (bylo == 0):

			pasuje1 = re.match(r'[^][]*\[[^][]*\][^][]*$',sl)
			pasuje2 = re.match(r'[^][]*\[[^][]*$',sl)

			if (pasuje1):
				nowe = re.sub(r'\[','',sl)
				nowe = re.sub(r'\]','',nowe)
				retVal[i] = (nowe,sl,1)  #0-normalne, 1-uszkodzenia
				i = i + 1
				sys.stderr.write(sl + " uszkodzone\n")

			elif (pasuje2):
				nowe = re.sub(r'\[','',sl)
				retVal[i] = (nowe,sl,1)  #0-normalne, 1-uszkodzenia
				i = i + 1
				bylo = 1
				sys.stderr.write(sl + " uszkodzone\n")

			else:
				retVal[i] = (sl,sl,0)  #0-normalne, 1-uszkodzenia
				i = i + 1
				sys.stderr.write(sl + " normalne\n")

		elif (bylo == 1):
			pasuje = re.match(r'[^][]*\][^][]*$',sl)
			if (pasuje):
				nowe = re.sub(r'\]','',sl)
				retVal[i] = (nowe,sl,1)  #0-normalne, 1-uszkodzenia
				i = i + 1
				bylo = 0
				sys.stderr.write(sl + " uszkodzone\n")

			else:
				sys.stderr.write(sl + " uszkodzone\n")
				retVal[i] = (sl,sl,1)  #0-normalne, 1-uszkodzenia
				i = i + 1

	return retVal



input = open(dane,'r',1)

i = 0
przerwa = 0

id_tabliczki = None;
for line_raw in input:
	line = cgi.escape(line_raw)
	#UWAGA: zakładamy, że początek tabliczki zaczyna się od '&P'
	if (line_raw[0] == '&' and line_raw[1] == 'P'):
		fragment = ""
		id_tabliczki = line_raw[2:8]
		sys.stderr.write("Nowe id tabliczki: " + id_tabliczki)
		i = 0
		przerwa = 1
	elif (przerwa != 0):
		przerwa = 0
	elif len(line)>0:
		if(id_tabliczki == None):
		    sys.stderr.write("Tablet id not known!!!\n" + line + "\n")
		    exit();
		slowa = filtruj(line)
		if (slowa == None):
			sys.stderr.write("error in line '" + line + "'")
			break

		for (sl,sl_original,x) in slowa:
			if (not (struktura_tabliczki(slowa[0][0])) and sl != slowa[0][0]):
				t = '';
				if (x == 0):
					t = "normal"
				else:	
					t = "broken"
				node1 = str(i) + id_tabliczki
				node2 = str(i+10) + id_tabliczki
			
				name = sl

				insert("""INSERT INTO reading(node1_id, node2_id, value, type) VALUES(%s, %s, %s, %s);""", (node1, node2, napisNull(name), napisNull(t)));
			i = i + 10
			

conn.commit()
cur.close()

input.close()
