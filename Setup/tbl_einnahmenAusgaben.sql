CREATE TABLE tbl_einnahmenAusgaben (
  Kontonummer  INTEGER NOT NULL,
  Identifier   TEXT    NOT NULL,
  Beschreibung TEXT    NOT NULL,
  Wert         REAL    NOT NULL,
  Turnus       TEXT    NOT NULL
  CHECK (Turnus IN ('einmalig', 'Monat', 'Quartal', 'Jahr') ),
  Zeitpunkt    DATE
);