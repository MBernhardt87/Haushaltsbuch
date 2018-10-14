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

CREATE TABLE tbl_katZuordnung (
    Kontonummer    INTEGER NOT NULL,
    Schluessel     TEXT    NOT NULL,
    Hauptkategorie TEXT    NOT NULL,
    Nebenkategorie TEXT    NOT NULL,
    Unterkategorie TEXT    NOT NULL,
    Identifier     TEXT    NOT NULL
);

CREATE TABLE tbl_parseZuordnung (
    Bank        TEXT NOT NULL,
    QuellSpalte TEXT NOT NULL,
    ZielSpalte  TEXT NOT NULL
);

CREATE TABLE tbl_einnahmenAusgaben (
    Kontonummer  INTEGER NOT NULL,
    Identifier   TEXT    NOT NULL,
    Beschreibung TEXT    NOT NULL,
    Wert         REAL    NOT NULL,
    Turnus       TEXT    NOT NULL
                         CHECK (Turnus IN ('einmalig', 'Monat', 'Quartal', 'Jahr') ),
    Zeitpunkt    DATE
);