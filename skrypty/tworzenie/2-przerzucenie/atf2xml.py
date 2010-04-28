# -*- coding: utf-8 -*-
from xml.dom import minidom
import sys
import re

current=sys.argv[3]
plik_wejsciowy = current  + "/../data/" + sys.argv[1]
prefiks_plikow_wyjsciowych = current  + "/../data/" + sys.argv[2]


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
#				sys.stderr.write(sl + " uszkodzone\n")

			elif (pasuje2):
				nowe = re.sub(r'\[','',sl)
				retVal[i] = (nowe,sl,1)  #0-normalne, 1-uszkodzenia
				i = i + 1
				bylo = 1
#				sys.stderr.write(sl + " uszkodzone\n")

			else:
				retVal[i] = (sl,sl,0)  #0-normalne, 1-uszkodzenia
				i = i + 1
#				sys.stderr.write(sl + " normalne\n")

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



input = open(plik_wejsciowy,'r',1)

show = ""
reading = ""
bylo = 0
i = 0
przerwa = 0

for line in input:
	if (line[0] == '&'):
		fragment = ""
		if (bylo == 0):
			bylo = 1
		else:
			fragment = fragment + '</graph>\n'
		id_tabliczki = line[1:8]
		fragment = fragment + '<graph id='
		fragment = fragment + '\"'+id_tabliczki+'\">\n'
		i = 0
		przerwa = 1
		show = show + fragment
		reading = reading + fragment
	elif (przerwa != 0):
		przerwa = 0
	else:
		slowa = filtruj(line)
		if (slowa == None):
			sys.stderr.write("error in line '" + line + "'")
			break

		for (sl,sl_original,x) in slowa:
			if (not (struktura_tabliczki(slowa[0][0]))):
				if (sl != slowa[0][0]): # pierwsze slowo zawsze jest struktura lub numerem linii
					reading = reading + '<graph_edge symbol=\"'
					if (x == 0):
						reading = reading + "normal"
					else:	
						reading = reading + "broken"
					reading = reading + '\" node1=\"'
					reading = reading + str(i) + '\" node2=\"'
					reading = reading + str(i+10) + "\" layer=\"0\">\n"
					reading = reading + "<list_predicate name=\"" + sl + "\">\n"
					reading = reading + "</list_predicate>\n"
					reading = reading + "</graph_edge>\n"
				else: sl = "@newline"


				show = show + '<graph_edge symbol=\" \" node1=\"'
				show = show + str(i) + '\" node2=\"'
				show = show + str(i+10) + "\" layer=\"0\">\n"
				show = show + "<list_predicate name=\"" + sl_original + "\">\n"
				show = show + "</list_predicate>\n"
				show = show + "</graph_edge>\n"

				i = i + 10
			else:
				show = show + '<graph_edge symbol=\" \" node1=\"'
				show = show + str(i) + '\" node2=\"'
				show = show + str(i+10) + "\" layer=\"0\">\n"
				show = show + "<list_predicate name=\"" + line + "\">\n"
				show = show + "</list_predicate>\n"
				show = show + "</graph_edge>\n"

				i = i + 10	

				break		


show = show + '</graph>'
reading = reading + '</graph>'

input.close()

output_show = open(prefiks_plikow_wyjsciowych+'_show.xml','w')
output_show.write(show)
output_show.close()

output_reading = open(prefiks_plikow_wyjsciowych+'_reading.xml','w')
output_reading.write(reading)
output_reading.close()
