DROP TABLE IF EXISTS TagValue CASCADE;

CREATE TABLE TagValue(
    id SERIAL,
    tag_id INT,
    value varchar(255),
    PRIMARY KEY(id),
    FOREIGN KEY (tag_id) REFERENCES Tag(id)
);