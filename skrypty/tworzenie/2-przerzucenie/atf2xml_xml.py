# -*- coding: utf-8 -*-
from xml.dom import minidom
import sys
import re

current=sys.argv[4]
plik_wejsciowy = current  + "/data/" + sys.argv[1]
plik_z_danymi = current + "/data/" + sys.argv[2]
plik_wyjsciowy = current  + "/data/" + sys.argv[3]


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


def inne_dane(id_tabliczki,input_dane):
	for line in input_dane:
		dane = line.split(" || ")
		if (dane[0] != id_tabliczki):
			print "Nie zgadza sie id tabliczki"
		else:
			result = "<publication>" + dane[1] + "</publication>\n"
			result = result + "<provenience>" + dane[2] + "</provenience>\n"
			result = result + "<period>" + dane[3] + "</period>\n"
			result = result + "<measurements>" + dane[4] + "</measurements>\n"
			result = result + "<genre>" + dane[5] + "</genre>\n"
			result = result + "<subgenre>" + dane[6] + "</subgenre>\n"
			result = result + "<collection>" + dane[7] + "</collection>\n"
			result = result + "<museum>" + dane[8] + "</museum>\n"
			return result

	return ""



input = open(plik_wejsciowy,'r',1)
input_dane = open(plik_z_danymi,'r',1)

show = ""
reading = ""
tablet="<tablets>\n"
bylo = 0
i = 0
przerwa = 0

for line in input:
	if (line[0] == '&' and line[1] == 'P'):
		fragment_graph = ""
		fragment_show = ""
		fragment_tablet = ""
		if (bylo == 0):
			bylo = 1
		else:
			tablet = tablet + '<text>\n'
			fragment_graph = fragment_graph + '</graph>\n'
			fragment_show = fragment_show + '</show>\n' + '</text>\n'
			fragment_tablet = fragment_tablet + '</tablet>\n'
		tablet = tablet + reading + fragment_graph + show + fragment_show +  fragment_tablet
		id_tabliczki = line[1:8]
		tablet = tablet + '<tablet>\n'
		tablet = tablet + '<idCDLI>' + id_tabliczki + '</idCDLI>\n'
		tablet = tablet + inne_dane(id_tabliczki,input_dane)
		i = 0
		przerwa = 1
		show = '<show>\n'
		reading = '<graph>\n'
	elif (przerwa != 0): #todo (#link)
		przerwa = 0
	else:

		slowa = filtruj(line)
		if (slowa == None):
			sys.stderr.write("error in line '" + line + "'")
			break

		for (sl,sl_original,x) in slowa:
			if (not (struktura_tabliczki(slowa[0][0]))):
				if (sl != slowa[0][0]): # pierwsze slowo zawsze jest struktura lub numerem linii
					reading = reading + '<edge symbol=\"'
					if (x == 0):
						reading = reading + "normal"
					else:	
						reading = reading + "broken"
					reading = reading + '\" node1=\"'
					reading = reading + str(i) + '\" node2=\"'
					reading = reading + str(i+10) + "\">"
					reading = reading + sl 
					reading = reading + "</edge>\n"
				else: sl = "@newline"


				show = show +  sl_original + " "

				i = i + 10
			else:

				show = show + line.strip()

				i = i + 10	

				break	
	
		show = show + "\n"


show = show + '</show>\n'
reading = reading + '</graph>\n'
text = '<text>\n' + reading + show + '</text>\n' 
tablet = tablet + text + '</tablet>\n' + "</tablets>\n"

input.close()
input_dane.close()

output_show = open(plik_wyjsciowy,'w')
output_show.write(tablet)
output_show.close()

