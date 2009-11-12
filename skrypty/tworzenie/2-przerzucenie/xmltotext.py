from xml.dom import minidom
import pg
conn = pg.connect(host="localhost", user="asia", passwd="achajka", dbname="sumlib")

plik = "nowy_show.xml"

xml = minidom.parse(plik)
tabliczki = xml.childNodes

for graph in tabliczki[0].getElementsByTagName("graph"):
	tab = '';
	graph_edges = graph.getElementsByTagName("graph_edge")
	graph_id = graph.getAttribute("id")
	id_=graph_id[1:]

	# iteracja po krawedziach grafu
	for edge in graph_edges:

		node1=edge.getAttribute("node1")
		node2=edge.getAttribute("node2")	
		symbol=edge.getAttribute("symbol")
		list_predicate=edge.getElementsByTagName("list_predicate")[0]
		name=list_predicate.getAttribute("name")
		if name == "@line_end":
			symbol = "<br>"
		if symbol.startswith('@'):
			symbol = symbol[:-1]
			symbol+= "<br>"
		tab+=symbol + "||"
	print id_ + ")" + tab
	print "**********************"
	conn.query("Update tabliczka set tekst='%s' where id=%s" % (tab, id_))