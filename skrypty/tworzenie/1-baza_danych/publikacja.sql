DROP TABLE IF EXISTS Publikacja CASCADE;

CREATE TABLE Publikacja (
    id SERIAL,
    wartosc VARCHAR(100) NOT NULL,
    PRIMARY KEY(id)
);

--moze bez tej tabeli, bo dla kazdej tabliczki jest inna
