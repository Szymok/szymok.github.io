-- Kompletność danych w SQL: przykład z wpisu na skszymon.eu
-- Dane są SYNTETYCZNE (wymyślone). Skrypt sprawdzony w SQLite; zapytania używają
-- standardowych funkcji (CASE, TRIM, LOWER, COALESCE, ROUND, CAST), więc działają
-- także w PostgreSQL, MySQL i SQL Server po drobnych zmianach składni (patrz komentarze).

-- 0. Dane przykładowe -------------------------------------------------------------
CREATE TABLE klienci (
    id                INTEGER PRIMARY KEY,
    nazwa             VARCHAR(100),
    typ               VARCHAR(10),      -- 'firma' albo 'osoba'
    nip               VARCHAR(20),
    email             VARCHAR(100),
    telefon           VARCHAR(30),
    miasto            VARCHAR(50),
    data_utworzenia   DATE              -- w SQLite tekst ISO: RRRR-MM-DD
);

INSERT INTO klienci VALUES
 (1,  'Alfa Sp. z o.o.',   'firma', '7010000001', 'biuro@alfa.example',        '221234567',       'Warszawa',  '2025-01-10'),
 (2,  'Beta SA',           'firma', NULL,         'kontakt@beta.example',      '+48 600 100 200', 'Kraków',    '2025-02-03'),
 (3,  'Gamma',             'firma', '',           'info@gamma.example',        NULL,              'Gdańsk',    '2025-02-15'),
 (4,  'Jan Kowalski',      'osoba', NULL,         'jan.k@example.com',         '501 222 333',     'Łódź',      '2025-03-01'),
 (5,  'Anna Nowak',        'osoba', NULL,         'n/d',                       '502 333 444',     NULL,        '2025-03-09'),
 (6,  'Delta Sp. z o.o.',  'firma', 'brak',       '-',                         '',                'Poznań',    '2025-04-20'),
 (7,  'Epsilon Sp. z o.o.','firma', '7010000003', 'epsilon@epsilon.example',   '123456789',       'Rzeszów',   '2025-04-28'),
 (8,  'Anna Wiśniewska',   'osoba', NULL,         'a.wisniewska@example.com',  ' ',               'Wrocław',   '2025-05-11'),
 (9,  'Zeta Sp. z o.o.',   'firma', '7010000004', 'zeta@zeta.example',         '123456780',       'Szczecin',  '2025-06-02'),
 (10, 'Eta',               'firma', '---',        NULL,                        '-',               'Lublin',    '2025-07-14'),
 (11, 'Piotr Zieliński',   'osoba', NULL,         'piotr.z@example.com',       '503 444 555',     'Katowice',  '2025-08-30'),
 (12, 'Theta SA',          'firma', '7010000007', 'theta@theta.example',       '224445566',       NULL,        '2025-09-18');

-- 1. Ile jest NULL-i w kolumnie? ---------------------------------------------------
-- COUNT(kolumna) liczy tylko wartości różne od NULL.
SELECT COUNT(*)                                        AS wiersze,
       ROUND(100.0 * COUNT(nip)     / COUNT(*), 1)     AS nip_proc,
       ROUND(100.0 * COUNT(email)   / COUNT(*), 1)     AS email_proc,
       ROUND(100.0 * COUNT(telefon) / COUNT(*), 1)     AS telefon_proc,
       ROUND(100.0 * COUNT(miasto)  / COUNT(*), 1)     AS miasto_proc
FROM klienci;

-- 2. Widok: co naprawdę uznajemy za brak? -------------------------------------------
-- Brakiem jest NULL, pusty tekst, same spacje i wartości zastępcze.
-- Listę wartości zastępczych zbuduj z własnych danych (patrz zapytanie 2b).
CREATE VIEW klienci_oceny AS
SELECT id, typ, data_utworzenia,
       CASE WHEN LOWER(TRIM(COALESCE(nazwa,   ''))) IN ('', '-', '--', '---', 'n/d', 'n/a', 'brak') THEN 0 ELSE 1 END AS nazwa_ok,
       CASE WHEN LOWER(TRIM(COALESCE(nip,     ''))) IN ('', '-', '--', '---', 'n/d', 'n/a', 'brak') THEN 0 ELSE 1 END AS nip_ok,
       CASE WHEN LOWER(TRIM(COALESCE(email,   ''))) IN ('', '-', '--', '---', 'n/d', 'n/a', 'brak') THEN 0 ELSE 1 END AS email_ok,
       CASE WHEN LOWER(TRIM(COALESCE(telefon, ''))) IN ('', '-', '--', '---', 'n/d', 'n/a', 'brak') THEN 0 ELSE 1 END AS telefon_ok,
       CASE WHEN LOWER(TRIM(COALESCE(miasto,  ''))) IN ('', '-', '--', '---', 'n/d', 'n/a', 'brak') THEN 0 ELSE 1 END AS miasto_ok
FROM klienci;

SELECT COUNT(*)                                          AS wiersze,
       ROUND(100.0 * SUM(nip_ok)     / COUNT(*), 1)      AS nip_proc,
       ROUND(100.0 * SUM(email_ok)   / COUNT(*), 1)      AS email_proc,
       ROUND(100.0 * SUM(telefon_ok) / COUNT(*), 1)      AS telefon_proc,
       ROUND(100.0 * SUM(miasto_ok)  / COUNT(*), 1)      AS miasto_proc
FROM klienci_oceny;

-- 2b. Skąd wziąć listę wartości zastępczych? Najczęstsze krótkie wartości w kolumnie.
SELECT LOWER(TRIM(email)) AS wartosc, COUNT(*) AS ile
FROM klienci
WHERE email IS NOT NULL AND LENGTH(TRIM(email)) < 6
GROUP BY LOWER(TRIM(email))
ORDER BY ile DESC;

-- 3. Kompletność warunkowa: NIP jest wymagany tylko dla firm -------------------------
SELECT COUNT(*)                                      AS firmy,
       SUM(nip_ok)                                   AS firmy_z_nip,
       ROUND(100.0 * SUM(nip_ok) / COUNT(*), 1)      AS nip_proc_firmy
FROM klienci_oceny
WHERE typ = 'firma';

-- 4. Trend w czasie: odsetek kompletnych rekordów wg miesiąca utworzenia ---------------
-- Rekord jest kompletny, gdy wszystkie pola wymagane są wypełnione
-- (NIP wymagany tylko dla firm). CAST + SUBSTR wycina RRRR-MM z daty
-- (w PostgreSQL można zamiast tego użyć DATE_TRUNC('month', data_utworzenia)).
SELECT SUBSTR(CAST(data_utworzenia AS VARCHAR(10)), 1, 7) AS miesiac,
       COUNT(*)                                           AS rekordy,
       SUM(CASE WHEN nazwa_ok = 1 AND email_ok = 1 AND telefon_ok = 1 AND miasto_ok = 1
                 AND (typ <> 'firma' OR nip_ok = 1) THEN 1 ELSE 0 END) AS kompletne
FROM klienci_oceny
GROUP BY SUBSTR(CAST(data_utworzenia AS VARCHAR(10)), 1, 7)
ORDER BY miesiac;

-- 5. Jeden wynik do scorecardu: wypełnione pola wymagane / wszystkie pola wymagane -----
-- Progi jak w arkuszu Scorecard: zielony od 95%, żółty 85-95%, czerwony poniżej 85%.
WITH pola AS (
    SELECT id,
           4 + CASE WHEN typ = 'firma' THEN 1 ELSE 0 END                                   AS wymagane,
           nazwa_ok + email_ok + telefon_ok + miasto_ok
             + CASE WHEN typ = 'firma' THEN nip_ok ELSE 0 END                              AS wypelnione
    FROM klienci_oceny
), wynik AS (
    SELECT ROUND(100.0 * SUM(wypelnione) / SUM(wymagane), 1) AS kompletnosc_proc
    FROM pola
)
SELECT kompletnosc_proc,
       CASE WHEN kompletnosc_proc >= 95 THEN 'zielony'
            WHEN kompletnosc_proc >= 85 THEN 'zolty'
            ELSE 'czerwony' END AS semafor
FROM wynik;
