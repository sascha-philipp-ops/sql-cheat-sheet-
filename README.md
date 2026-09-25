# 🗄️ sql-cheat-sheet

A structured overview of core SQL commands for daily use, learning, and quick reference.

## 📌 Overview
- **DDL (Data Definition Language):** Create, modify, and drop tables (`CREATE`, `ALTER`, `DROP`)
- **DML (Data Manipulation Language):** Insert, update, and delete data (`INSERT`, `UPDATE`, `DELETE`)
- **DQL (Data Query Language):** Filter, sort, group, and join data (`SELECT`, `WHERE`, `JOIN`, `GROUP BY`)

---

## 📁 Repository Content
- **`schema.sql`**: Complete E-Commerce database script including tables, constraints, sample data, joins, subqueries, and views.

## 🚀 Quick Start
You can run the script in any standard SQL environment (VS Code, DBeaver, pgAdmin, etc.):

```sql
-- Example query from schema.sql
SELECT k.vorname, k.nachname, COUNT(b.bestell_id) AS anzahl_bestellungen
FROM kunden k
LEFT JOIN bestellungen b ON k.kunden_id = b.kunde_id
GROUP BY k.kunden_id, k.vorname, k.nachname;
