<?xml version="1.0"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">


<xs:complexType name="edge_type">
	<xs:simpleContent>
		<xs:extension base="xs:string">
			<xs:attribute name="symbol" type="xs:string"/>
			<xs:attribute name="node1" type="xs:integer"/>
			<xs:attribute name="node2" type="xs:integer"/>
		</xs:extension>
	</xs:simpleContent>
</xs:complexType>

<xs:complexType name="graph_type">
	<xs:sequence>
		<xs:element name="edge" minOccurs="0" maxOccurs="unbounded" type="edge_type"/>
	</xs:sequence>
</xs:complexType>

<xs:complexType name="text_type">
	<xs:sequence>
		<xs:element name="graph" type="graph_type"/>
		<xs:element name="show" type="xs:string"/>
	</xs:sequence>
</xs:complexType>

<xs:complexType name="tablet_type">
	<xs:sequence>
		<xs:element name="idCDLI" type="xs:string"/>
		<xs:element name="publication" type="xs:string"/>
		<xs:element name="provenience" type="xs:string"/>
		<xs:element name="period" type="xs:string"/>
		<xs:element name="measurements" type="xs:string"/>
		<xs:element name="genre" type="xs:string"/>
		<xs:element name="subgenre" type="xs:string"/>
		<xs:element name="collection" type="xs:string"/>
		<xs:element name="museum" type="xs:string"/>
		<xs:element name="text" type="text_type"/>		
	</xs:sequence>
</xs:complexType>

<xs:element name="tablets">
  <xs:complexType>
    <xs:sequence>
      <xs:element name="tablet" type="tablet_type" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>
</xs:element>

</xs:schema>