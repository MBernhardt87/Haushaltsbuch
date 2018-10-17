select Buchungsdatum, Hauptkategorie,Nebenkategorie,Unterkategorie,Betrag from tbl_kontostand as konto inner join tbl_katZuordnung as kat on konto.Schluessel=kat.Schluessel where konto.kontonummer=
