CREATE TABLE tcosa (
  cod_cosa int,
  des_cosa varchar(50),
  obs_cosa varchar(255),
  PRIMARY KEY(cod_cosa)
);

INSERT INTO tcosa VALUES (1, 'Primera cosa', '');
INSERT INTO tcosa VALUES (2, 'Segunda cosa', '');
INSERT INTO tcosa VALUES (3, 'Tercera cosa', NULL);
INSERT INTO tcosa VALUES (4, 'Cuarta cosa', '');
INSERT INTO tcosa VALUES (5, 'Quinta cosa', NULL);
INSERT INTO tcosa VALUES (6, 'Sexta cosa', '');
INSERT INTO tcosa VALUES (7, 'Séptima cosa', NULL);
INSERT INTO tcosa VALUES (8, 'Octava cosa', NULL);
INSERT INTO tcosa VALUES (9, 'Novena cosa', '');
INSERT INTO tcosa VALUES (10, 'Décima cosa', NULL);

CREATE TABLE tvacia (
  cod_vacio int
);
