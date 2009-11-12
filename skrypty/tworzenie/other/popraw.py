from xml.dom import minidom

#Open XML document using minidom parser
show = minidom.parse('show.xml')
sign = minidom.parse('sign.xml')
sign_name = minidom.parse('sign_name.xml')


#pobieramy elementy struktury dokumentu XML
sign_nameNodes = sign_name.childNodes
signNodes = sign.childNodes
showNodes = show.childNodes




#iteracja po grafach
for i in range(showNodes[0].getElementsByTagName("graph").length):
	
	showGraph = (showNodes[0].getElementsByTagName("graph"))[i]
	signGraph = signNodes[0].getElementsByTagName("graph")[i]
	sign_nameGraph = sign_nameNodes[0].getElementsByTagName("graph")[i]


	graph_edges_Show = showGraph.getElementsByTagName("graph_edge")
	graph_edges_Sign = signGraph.getElementsByTagName("graph_edge")
	graph_edges_Sign_name = sign_nameGraph.getElementsByTagName("graph_edge")

	
	j=0
	k=0
	i=0
	# iteracja po krawedziach grafu show
	for currentShow in graph_edges_Show:
	

		#currentShow = graph_edges_Show[i]
		#if currentShow.getAttribute("symbol")==' ':
		#	graph_edges.
		#	continue
		currentSign = graph_edges_Sign[j]
		currentSign_name = graph_edges_Sign_name[k]



		kon = currentShow.getAttribute("node2")
		pocz = currentShow.getAttribute("node1")

		kon_sign = currentSign.getAttribute("node2")
		kon_sign_name = currentSign_name.getAttribute("node2")

		currentShow.setAttribute("node1",str(i*10))
		currentSign.setAttribute("node1",str(i*10))
		currentSign_name.setAttribute("node1",str(i*10))

		currentShow.setAttribute("node2",str((i+1)*10))

		# te wartosci pozniej moga zostac nadpisane
		currentSign.setAttribute("node2",str((i+1)*10))
		currentSign_name.setAttribute("node2",str((i+1)*10))


		ile_sign=0
		ile_sign_name=0

		delta = int(kon) - int(pocz)
		if delta>1:
			#print str(i) + " " + str(j) + " " + str(k)
			#print  pocz + "->" + kon
			if kon_sign != kon:
				ile_sign = int(kon) - int(kon_sign)

			if kon_sign_name != kon:
				ile_sign_name = int(kon) - int(kon_sign_name)


		for ij in range(ile_sign):
			currentSign=graph_edges_Sign[j+ij]
			currentSign.setAttribute("node1",str(i*10 + ij))
			currentSign.setAttribute("node2",str(i*10 + ij + 1))
		
		graph_edges_Sign[j+ile_sign].setAttribute("node1",str(i*10 + ile_sign))	
		graph_edges_Sign[j+ile_sign].setAttribute("node2",str((i+1)*10))


		for ik in range(ile_sign_name):
			currentSign_name=graph_edges_Sign_name[k+ik]
			currentSign_name.setAttribute("node1",str(i*10 + ik))
			currentSign_name.setAttribute("node2",str(i*10 + ik + 1))
		
		graph_edges_Sign_name[k+ile_sign_name].setAttribute("node1",str(i*10 + ile_sign_name))	
		graph_edges_Sign_name[k+ile_sign_name].setAttribute("node2",str((i+1)*10))
			
		

		j = j + 1 + ile_sign
		k = k + 1 + ile_sign_name
		i = i + 1


output_show = open('nowy_show.xml','w')
output_show.write(show.toxml())
output_show.close()
output_sign = open('nowy_sign.xml','w')
output_sign.write(sign.toxml())
output_sign.close()
output_sign_name = open('nowy_sign_name.xml','w')
output_sign_name.write(sign_name.toxml())
output_sign_name.close()



