CREATE TABLE tbl_kontostand (
  Kontonummer      INTEGER NOT NULL,
  Buchtungsdatum   DATE    NOT NULL,
  Sender           TEXT    NOT NULL,
  IBAN             TEXT,
  BIC              TEXT,
  Buchungstyp      TEXT,
  Verwendungszweck TEXT,
  Schluessel       TEXT    NOT NULL,
  Betrag           REAL    NOT NULL,
  Monat            INTEGER NOT NULL
  CHECK (Monat > 0 AND 
         Monat <= 12),
  Jahr             INTEGER NOT NULL
  CHECK (Jahr > 1990) 
);