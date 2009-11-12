DROP TABLE IF EXISTS Tagi CASCADE;

CREATE TABLE Tag(
    id SERIAL,
    wezel1_id INTEGER NOT NULL, -- id_tabliczki * 100 000 + id_wezla
    wezel2_id INTEGER NOT NULL,
    typ varchar(10) default NULL
    CHECK (typ IN ('osoba','miejsce','liczba', 'miara', 'data')),
    PRIMARY KEY(id)
);