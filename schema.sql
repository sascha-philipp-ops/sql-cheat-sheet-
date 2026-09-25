-- ==============================================================================
-- Ausarbeitung Sascha Philipp 
-- UMFANGREICHES SQL CHEAT SHEET & PRAXIS-SKRIPT
-- Beschreibung: DDL, DML und DQL für ein E-Commerce Schema
-- Kompatibel mit: PostgreSQL, MySQL (8.0+), SQLite (3.25+)
-- ==============================================================================

-- ##############################################################################
-- 🔵 BEREICH 1: DDL (DATA DEFINITION LANGUAGE)
-- Tabellenstruktur, Primär-/Fremdschlüssel, Constraints & Indizes
-- ##############################################################################

-- 1.0 Aufräumen (Alte Strukturen entfernen)

DROP VIEW IF EXISTS v_kunden_umsatz;
DROP TABLE IF EXISTS bestellpositionen;
DROP TABLE IF EXISTS bestellungen;
DROP TABLE IF EXISTS produkte;
DROP TABLE IF EXISTS kategorien;
DROP TABLE IF EXISTS kunden;

-- 1.1 Tabellen erstellen (CREATE TABLE)

-- Stamm-Tabelle: Kunden
CREATE TABLE kunden (
kunden_id INT PRIMARY KEY,
vorname VARCHAR(50) NOT NULL,
nachname VARCHAR(50) NOT NULL,
email VARCHAR(100) NOT NULL UNIQUE,
stadt VARCHAR(50),
registriert_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
status VARCHAR(20) DEFAULT 'aktiv' CHECK (status IN ('aktiv', 'inaktiv', 'gesperrt'))
);

-- Stamm-Tabelle: Kategorien
CREATE TABLE kategorien (
kategorie_id INT PRIMARY KEY,
kategorie_name VARCHAR(50) NOT NULL UNIQUE
);

-- Produkt-Tabelle mit Fremdschlüssel auf Kategorien
CREATE TABLE produkte (
produkt_id INT PRIMARY KEY,
kategorie_id INT,
produkt_name VARCHAR(100) NOT NULL,
preis DECIMAL(10, 2) NOT NULL CHECK (preis >= 0),
lagerbestand INT DEFAULT 0 CHECK (lagerbestand >= 0),
FOREIGN KEY (kategorie_id) REFERENCES kategorien(kategorie_id) ON DELETE SET NULL
);

-- Transaktions-Tabelle: Bestellungen
CREATE TABLE bestellungen (
bestell_id INT PRIMARY KEY,
kunden_id INT NOT NULL,
bestelldatum DATE NOT NULL,
status VARCHAR(20) DEFAULT 'offen' CHECK (status IN ('offen', 'bezahlt', 'versendet', 'storniert')),
FOREIGN KEY (kunden_id) REFERENCES kunden(kunden_id) ON DELETE CASCADE
);

-- N:M Verbindungstabelle: Bestellpositionen
CREATE TABLE bestellpositionen (
bestell_id INT,
produkt_id INT,
menge INT NOT NULL CHECK (menge > 0),
einzelpreis DECIMAL(10, 2) NOT NULL,
PRIMARY KEY (bestell_id, produkt_id),
FOREIGN KEY (bestell_id) REFERENCES bestellungen(bestell_id) ON DELETE CASCADE,
FOREIGN KEY (produkt_id) REFERENCES produkte(produkt_id)
);

-- 1.2 Performance-Optimierung (CREATE INDEX)

CREATE INDEX idx_kunden_email ON kunden(email);
CREATE INDEX idx_bestellungen_kunde ON bestellungen(kunden_id);
CREATE INDEX idx_produkte_kategorie ON produkte(kategorie_id);

-- ##############################################################################
-- 🟢 BEREICH 2: DML (DATA MANIPULATION LANGUAGE)
-- Daten einfügen (INSERT), aktualisieren (UPDATE) & löschen (DELETE)
-- ##############################################################################

-- 2.1 Datensätze einfügen (INSERT INTO)

-- Kategorien
INSERT INTO kategorien (kategorie_id, kategorie_name) VALUES
(1, 'Elektronik'),
(2, 'Bücher'),
(3, 'Kleidung');

-- Produkte
INSERT INTO produkte (produkt_id, kategorie_id, produkt_name, preis, lagerbestand) VALUES
(101, 1, 'Smartphone Alpha', 699.99, 50),
(102, 1, 'Wireless Kopfhörer', 129.50, 100),
(103, 2, 'SQL Handbuch & Praxis', 49.90, 30),
(104, 2, 'Python für Einsteiger', 39.90, 20),
(105, 3, 'Laufschuhe Pro', 89.95, 15);

-- Kunden
INSERT INTO kunden (kunden_id, vorname, nachname, email, stadt, status) VALUES
(1, 'Max', 'Mustermann', 'max@example.com', 'Berlin', 'aktiv'),
(2, 'Erika', 'Musterfrau', 'erika@example.com', 'Hamburg', 'aktiv'),
(3, 'Alex', 'Schmidt', 'alex@example.com', 'München', 'inaktiv'),
(4, 'Laura', 'Weber', 'laura@example.com', 'Berlin', 'aktiv');

-- Bestellungen
INSERT INTO bestellungen (bestell_id, kunden_id, bestelldatum, status) VALUES
(1001, 1, '2026-01-10', 'versendet'),
(1002, 1, '2026-02-01', 'bezahlt'),
(1003, 2, '2026-02-15', 'offen'),
(1004, 4, '2026-02-20', 'bezahlt');

-- Bestellpositionen
INSERT INTO bestellpositionen (bestell_id, produkt_id, menge, einzelpreis) VALUES
(1001, 101, 1, 699.99),
(1001, 102, 2, 129.50),
(1002, 103, 1, 49.90),
(1003, 105, 1, 89.95),
(1004, 101, 1, 699.99),
(1004, 104, 2, 39.90);

-- 2.2 Daten aktualisieren (UPDATE)

-- Lagerbestand nach Kauf reduzieren
UPDATE produkte
SET lagerbestand = lagerbestand - 1
WHERE produkt_id = 101;

-- Kundentyp basierend auf Kriterien anpassen
UPDATE kunden
SET status = 'gesperrt'
WHERE stadt = 'Berlin' AND status = 'inaktiv';

-- 2.3 Daten löschen (DELETE)

-- Löschen aller inaktiven Kunden
DELETE FROM kunden WHERE status = 'inaktiv';

-- ##############################################################################
-- 🟠 BEREICH 3: DQL (DATA QUERY LANGUAGE)
-- Daten abfragen, filtern, verknüpfen & analysieren
-- ##############################################################################

-- 3.1 Basic Queries: Filtern, Sortieren & Begrenzen

SELECT produkt_name, preis, lagerbestand
FROM produkte
WHERE preis > 50.00 AND lagerbestand > 0
ORDER BY preis DESC
LIMIT 5;

-- 3.2 Aggregationen: GROUP BY & HAVING

SELECT
k.kategorie_name,
COUNT(p.produkt_id) AS anzahl_produkte,
AVG(p.preis) AS avg_preis
FROM kategorien k
JOIN produkte p ON k.kategorie_id = p.kategorie_id
GROUP BY k.kategorie_id, k.kategorie_name
HAVING AVG(p.preis) > 50.00;

-- 3.3 Verknüpfungen: Mehrfach-JOINs

SELECT
k.vorname || ' ' || k.nachname AS kundenname,
b.bestell_id,
p.produkt_name,
bp.menge,
(bp.menge * bp.einzelpreis) AS gesamtpreis
FROM kunden k
JOIN bestellungen b ON k.kunden_id = b.kunden_id
JOIN bestellpositionen bp ON b.bestell_id = bp.bestell_id
JOIN produkte p ON bp.produkt_id = p.produkt_id
ORDER BY b.bestell_id;

-- 3.4 Subqueries (Unterabfragen)

-- Skalare Unterabfrage: Produkte über dem Durchschnittspreis
SELECT produkt_name, preis
FROM produkte
WHERE preis > (SELECT AVG(preis) FROM produkte);

-- Subquery mit IN: Kunden mit mindestens einer Bestellung
SELECT vorname, nachname, email
FROM kunden
WHERE kunden_id IN (SELECT DISTINCT kunden_id FROM bestellungen);

-- 3.5 Common Table Expressions (CTE mit WITH)

WITH KundenUmsatz AS (
SELECT
b.kunden_id,
SUM(bp.menge * bp.einzelpreis) AS gesamtumsatz
FROM bestellungen b
JOIN bestellpositionen bp ON b.bestell_id = bp.bestell_id
GROUP BY b.kunden_id
)
SELECT
k.vorname,
k.nachname,
COALESCE(ku.gesamtumsatz, 0.00) AS umgesetzt_euro
FROM kunden k
LEFT JOIN KundenUmsatz ku ON k.kunden_id = ku.kunden_id;

-- 3.6 Window Functions (Fensterfunktionen)

SELECT
kunden_id,
bestell_id,
bestelldatum,
ROW_NUMBER() OVER (PARTITION BY kunden_id ORDER BY bestelldatum) AS bestellung_nr
FROM bestellungen;

-- ##############################################################################
-- 🟣 BEREICH 4: VIEWS (VIRTUELLE TABELLEN)
-- ##############################################################################

-- 4.1 View zur Wiederverwendung von komplexen Abfragen erstellen

CREATE VIEW v_kunden_umsatz AS
SELECT
k.kunden_id,
k.vorname,
k.nachname,
COUNT(DISTINCT b.bestell_id) AS anzahl_bestellungen,
COALESCE(SUM(bp.menge * bp.einzelpreis), 0.00) AS gesamt_ausgegeben
FROM kunden k
LEFT JOIN bestellungen b ON k.kunden_id = b.kunden_id
LEFT JOIN bestellpositionen bp ON b.bestell_id = bp.bestell_id
GROUP BY k.kunden_id, k.vorname, k.nachname;

-- 4.2 Abfrage der erstellten View

SELECT * FROM v_kunden_umsatz WHERE gesamt_ausgegeben > 0;
