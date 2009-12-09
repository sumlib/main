DROP TABLE IF EXISTS Tag CASCADE;

CREATE TABLE Tag(
    id SERIAL,
    node1_id INTEGER NOT NULL, -- id_tabliczki * 100 000 + id_wezla
    node2_id INTEGER NOT NULL,
    type varchar(10) default NULL
    CHECK (type IN ('person','place','number', 'measure', 'date')),
    PRIMARY KEY(id)
);