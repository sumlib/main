-- typ tabliczki (administrative itp)
DROP TABLE IF EXISTS Genre CASCADE;

CREATE TABLE Genre (
    id SERIAL,
    value VARCHAR(100) NOT NULL,
    PRIMARY KEY(id)
);







