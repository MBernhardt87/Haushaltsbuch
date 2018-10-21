CREATE TABLE tbl_konto (
  Kontonummer INTEGER UNIQUE
  NOT NULL ON CONFLICT ROLLBACK,
  Inhaber     TEXT,
  Bank        TEXT    NOT NULL,
  Waehrung    TEXT    DEFAULT EUR
  CHECK (Waehrung IN ('EUR', 'USD', 'GBP') ),
  Typ         TEXT    CHECK (Typ IN ('Giro', 'Spar', 'Depot') ) 
  DEFAULT Giro
);