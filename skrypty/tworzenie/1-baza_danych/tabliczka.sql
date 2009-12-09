DROP TABLE IF EXISTS Tablet CASCADE;


CREATE TABLE Tablet(
    id SERIAL,

--dane id_cdli, publikacja, prowiniencja, okres, rozmiary, typ, podtyp, kolekcja, muzeum
    id_cdli VARCHAR(10) NOT NULL,
    publication VARCHAR(100),
    measurements VARCHAR(15),
    date_of_origin VARCHAR(100), -- COMMENT 'wynikająca z tabliczki data powstania', 
    provenience_id INT,
    period_id INT,
    genre_id INT,
    subgenre_id INT,
    collection_id INT,
    museum VARCHAR(100),

--tekst w naszym formacie
    show_text TEXT NULL,

--warunki na tabele
    PRIMARY KEY(id),
    FOREIGN KEY (provenience_id) REFERENCES Provenience(id),
    FOREIGN KEY (period_id) REFERENCES Period(id),
    FOREIGN KEY (genre_id) REFERENCES Genre(id),
    FOREIGN KEY (subgenre_id) REFERENCES Genre(id),
    FOREIGN KEY (collection_id) REFERENCES Collection(id)
);
