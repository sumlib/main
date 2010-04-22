DROP TABLE IF EXISTS Reading CASCADE;

CREATE TABLE Reading(
    id SERIAL,
    node1_id BIGINT NOT NULL, -- tablet_id * 100 000 + node_id
    node2_id BIGINT NOT NULL,
    value VARCHAR(50) NOT NULL,
    type varchar(255) NOT NULL,
    CHECK (type IN ('normal', 'broken')),
    PRIMARY KEY(id)
);
