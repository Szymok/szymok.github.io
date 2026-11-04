-- ============================================================================
-- SKRYPT INICJALIZACYJNY: TABELA klienci, slownik_pna ORAZ zamowienia
-- Dialekt: PostgreSQL (testowane na wersji 16). Dane w całości syntetyczne.
-- ============================================================================

DROP TABLE IF EXISTS zamowienia;
DROP TABLE IF EXISTS klienci;
DROP TABLE IF EXISTS slownik_pna;

CREATE TABLE klienci (
    id INTEGER PRIMARY KEY,
    typ_klienta VARCHAR(10),          -- 'B2B' lub 'B2C'
    imie_nazwisko VARCHAR(100),       -- osoba kontaktowa lub klient B2C
    nazwa_firmy VARCHAR(150),         -- wymagane dla B2B
    nip VARCHAR(20),                  -- wymagane dla B2B (10 cyfr bez kresek)
    email VARCHAR(255),               -- wymagane dla wszystkich
    telefon VARCHAR(20),              -- standard E.164: +48XXXXXXXXX
    kod_pocztowy VARCHAR(10),         -- format NN-NNN
    miasto VARCHAR(100),
    data_urodzenia DATE,              -- YYYY-MM-DD
    data_rejestracji DATE,            -- YYYY-MM-DD
    data_ostatniego_zakupu DATE,      -- YYYY-MM-DD
    status_klienta VARCHAR(20),       -- słownik: 'AKTYWNY', 'ZAWIESZONY', 'ZAMKNIETY'
    rabat_proc NUMERIC(5,2)           -- dozwolony zakres: 0 do 50 (%)
);

CREATE TABLE slownik_pna (
    kod_pocztowy VARCHAR(10) PRIMARY KEY,
    miasto VARCHAR(100),
    okr_prefiks VARCHAR(2)
);

CREATE TABLE zamowienia (
    id_zamowienia INTEGER PRIMARY KEY,
    klient_id INTEGER,
    data_zamowienia DATE,
    status_zamowienia VARCHAR(20),    -- 'NOWE', 'W_REALIZACJI', 'ZREALIZOWANE', 'ANULOWANE'
    kwota_brutto NUMERIC(10,2)
);

-- Wycinek Oficjalnego Spisu PNA Poczty Polskiej na potrzeby zestawu testowego
INSERT INTO slownik_pna (kod_pocztowy, miasto, okr_prefiks) VALUES
('00-001', 'Warszawa', '00'),
('00-950', 'Warszawa', '00'),
('02-676', 'Warszawa', '02'),
('80-001', 'Gdańsk', '80'),
('80-299', 'Gdańsk', '80'),
('81-301', 'Gdynia', '81'),
('30-001', 'Kraków', '30'),
('31-150', 'Kraków', '31'),
('60-101', 'Poznań', '60'),
('50-001', 'Wrocław', '50'),
('40-001', 'Katowice', '40'),
('90-001', 'Łódź', '90'),
('70-001', 'Szczecin', '70'),
('15-001', 'Białystok', '15'),
('16-400', 'Suwałki', '16');

-- 20 rekordów testowych (1-10: B2B, 11-20: B2C)
INSERT INTO klienci VALUES
(1,  'B2B', 'Jan Kowalski',          'TechPol Sp. z o.o.',      '7010001016',    'jan.kowalski@techpol.example',      '+48501234567', '00-001', 'Warszawa',  '1985-04-12', '2022-01-15', '2026-10-10', 'AKTYWNY',   10),
(2,  'B2B', 'Anna Nowak',            'Nordic Data S.A.',        '7010001022',    'anna.nowak@nordicdata.example',     '+48602345678', '80-001', 'Gdańsk',    '1990-08-23', '2023-03-10', '2026-09-20', 'AKTYWNY',   15),
(3,  'B2B', 'Piotr Wiśniewski',      'KrakSoft Sp. z o.o.',     '7010001039',    'piotr@kraksoft.example',            '+48512345678', '30-001', 'Kraków',    '1978-11-05', '2021-06-01', '2026-10-01', 'AKTYWNY',   20),
(4,  'B2B', 'Marek Zieliński',       'Baltic Logistics',        '7010001045',    'marek@balticlogistics.example',     '+48609876543', '81-301', 'Gdynia',    '1982-02-19', '2024-02-20', '2026-08-15', 'AKTYWNY',    5),
(5,  'B2B', 'Katarzyna Dąbrowska',   'Poznań Trade Sp.k.',      '7010001051',    'k.dabrowska@poznantrade.example',   '+48661234567', '60-101', 'Poznań',    '1992-07-30', '2023-11-11', '2026-10-25', 'AKTYWNY',   10),
(6,  'B2B', 'Tomasz Kamiński',       'Alfa Consulting',         '1234567890',    'tomasz@alfaconsulting.example',     '+48721234567', '50-001', 'Wrocław',   '1988-05-14', '2025-01-10', '2026-07-01', 'AKTYWNY',   12),
(7,  'B2B', 'Agnieszka Lewandowska', 'Silesia IT Sp. z o.o.',   '7010001069',    'agnieszka@silesia-it.example',      '+48691234567', '00-950', 'Kraków',    '1986-09-09', '2024-05-05', '2026-09-12', 'AKTYWNY',    0),
(8,  'B2B', 'Michał Wójcik',         '',                        NULL,            'michal.wojcik@example.com',     '+48531234567', '40-001', 'Katowice',  '1991-12-01', '2025-04-18', '2026-10-02', 'AKTYWNY',    5),
(9,  'B2B', 'Jan Kowalski',          'TechPol Oddział',         '7010001016',    'JAN.KOWALSKI@techpol.example',      '+48501234567', '00-001', 'Warszawa',  '1985-04-12', '2025-08-01', '2026-10-11', 'AKTYWNY',   10),
(10, 'B2B', 'Paweł Kozłowski',       'Omega Budownictwo',       '701-000-10-74', 'pawel@omegabud.example',            '+48781234567', '31-150', 'Kraków',    '1975-03-22', '2020-09-01', '2024-12-01', 'ZAMKNIETY',  0),
(11, 'B2C', 'Magdalena Jankowska',   NULL,                      NULL,            'magda.jankowska@example.com',    '+48505111222', '90-001', 'Łódź',      '1995-06-15', '2024-01-20', '2026-10-18', 'AKTYWNY',    0),
(12, 'B2C', 'Krzysztof Mazur',       NULL,                      NULL,            'krzysztof.mazur@example.com',        '+48606222333', '70-001', 'Szczecin',  '1983-10-08', '2023-07-14', '2026-09-30', 'AKTYWNY',    5),
(13, 'B2C', 'Ewa Krawczyk',          NULL,                      NULL,            'ewa.krawczyk@example.com',         '+48515333444', '15-001', 'Białystok', '1998-01-25', '2025-02-01', '2026-10-05', 'AKTYWNY',    0),
(14, 'B2C', 'Marcin Kaczmarek',      NULL,                      NULL,            'marcin.kaczmarek@example.com',  '+48695444555', '16-400', 'Suwałki',   '1980-07-19', '2022-11-11', '2026-05-20', 'ZAWIESZONY', 0),
(15, 'B2C', 'Dorota Piotrowska',     NULL,                      NULL,            '   ',                          '+48725555666', '02-676', 'Warszawa',  '1993-04-03', '2025-06-10', '2026-08-01', 'AKTYWNY',    0),
(16, 'B2C', 'Adam Grabowski',        NULL,                      NULL,            'adam.grabowski.example.com',     '12345',        '80-299', 'Gdańsk',    '1996-12-12', '2025-09-01', '2026-09-15', 'AKTYWNY',    0),
(17, 'B2C', 'Zofia Pawłowska',       NULL,                      NULL,            'zofia.pawlowska@example.com',     '+48000000000', '79-100', 'Koszalin',  '1989-03-17', '2024-08-12', '2026-10-12', 'AKTYWNY',    0),
(18, 'B2C', 'Łukasz Michalski',      NULL,                      NULL,            'lukasz.michalski@example.com',   '+48508777888', '00-001', 'Warszawa',  '2030-01-01', '2026-10-01', '2025-05-01', 'AKTYWNY',    0),
(19, 'B2C', 'Natalia Król',          NULL,                      NULL,            'natalia.krol@example.com',     '+48601888999', '30-001', 'Kraków',    '1899-01-01', '2023-04-01', '2026-06-15', 'VIP',       85),
(20, 'B2C', 'magdalena jankowska',   NULL,                      NULL,            'm.jankowska2@example.com',       '+48505111222', '90001',  'Łódź',      '1995-06-15', '2026-01-10', '2026-10-19', 'AKTYWNY',    0);

INSERT INTO zamowienia VALUES
(101, 1,  '2026-10-10', 'ZREALIZOWANE', 12500.00),
(102, 2,  '2026-09-20', 'ZREALIZOWANE',  8400.00),
(103, 3,  '2026-10-01', 'W_REALIZACJI',  4300.00),
(104, 10, '2026-10-28', 'W_REALIZACJI',  9900.00), -- BŁĄD: klient id=10 ma status ZAMKNIETY
(105, 11, '2026-10-18', 'ZREALIZOWANE',   350.00);

-- ============================================================================
-- 12 REGUŁ (każda zwraca rekordy do naprawy)
-- ============================================================================

-- R01: Wykrycie rekordów z brakującym lub pozornie wypełnionym adresem e-mail
SELECT
    id,
    typ_klienta,
    imie_nazwisko,
    email
FROM klienci
WHERE email IS NULL
   OR TRIM(email) = ''
   OR LOWER(TRIM(email)) IN ('brak', 'nie podano', 'n/a', 'null', '-');

-- R02: Kompletność warunkowa — brak NIP lub nazwy firmy u klientów B2B
SELECT
    id,
    typ_klienta,
    imie_nazwisko,
    nazwa_firmy,
    nip
FROM klienci
WHERE typ_klienta = 'B2B'
  AND (
      nip IS NULL OR TRIM(nip) = ''
      OR nazwa_firmy IS NULL OR TRIM(nazwa_firmy) = ''
  );

-- R03: Walidacja NIP (10 cyfr + suma kontrolna, wagi 6-5-7-2-3-4-5-6-7 mod 11)
WITH b2b AS (
    SELECT id, nazwa_firmy, nip,
           CASE WHEN nip ~ '^[1-9][0-9]{9}$' THEN
               (CAST(SUBSTR(nip, 1, 1) AS INTEGER) * 6 +
                CAST(SUBSTR(nip, 2, 1) AS INTEGER) * 5 +
                CAST(SUBSTR(nip, 3, 1) AS INTEGER) * 7 +
                CAST(SUBSTR(nip, 4, 1) AS INTEGER) * 2 +
                CAST(SUBSTR(nip, 5, 1) AS INTEGER) * 3 +
                CAST(SUBSTR(nip, 6, 1) AS INTEGER) * 4 +
                CAST(SUBSTR(nip, 7, 1) AS INTEGER) * 5 +
                CAST(SUBSTR(nip, 8, 1) AS INTEGER) * 6 +
                CAST(SUBSTR(nip, 9, 1) AS INTEGER) * 7) % 11
           END AS kontrola
    FROM klienci
    WHERE typ_klienta = 'B2B'
)
SELECT id, nazwa_firmy, nip,
       CASE
           WHEN nip IS NULL OR TRIM(nip) = '' THEN 'Brak NIP'
           WHEN nip !~ '^[1-9][0-9]{9}$'      THEN 'Błędny format (10 cyfr bez kresek)'
           WHEN kontrola = 10                 THEN 'Reszta mod 11 = 10: taki NIP nie istnieje'
           ELSE 'Błędna cyfra kontrolna'
       END AS powod_bledu
FROM b2b
WHERE nip IS NULL OR TRIM(nip) = ''
   OR nip !~ '^[1-9][0-9]{9}$'
   OR kontrola IS DISTINCT FROM CAST(SUBSTR(nip, 10, 1) AS INTEGER);

-- R04: Walidacja składni adresu e-mail wg praktycznych wytycznych RFC 5321 / 5322
SELECT
    id,
    imie_nazwisko,
    email
FROM klienci
WHERE email IS NULL
   OR LENGTH(TRIM(email)) > 254
   OR email LIKE '%..%'
   OR email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

-- R05: Walidacja kodu pocztowego — format NN-NNN oraz obecność w słowniku PNA
SELECT
    k.id,
    k.imie_nazwisko,
    k.kod_pocztowy,
    k.miasto,
    CASE
        WHEN k.kod_pocztowy IS NULL OR k.kod_pocztowy !~ '^[0-9]{2}-[0-9]{3}$'
            THEN 'Błędny format składniowy (wymagany NN-NNN)'
        ELSE 'Kodu nie ma w słowniku PNA'
    END AS diagnoza
FROM klienci k
LEFT JOIN slownik_pna p ON k.kod_pocztowy = p.kod_pocztowy
WHERE k.kod_pocztowy IS NULL
   OR k.kod_pocztowy !~ '^[0-9]{2}-[0-9]{3}$'
   OR p.kod_pocztowy IS NULL;

-- R06: Walidacja polskiego numeru telefonu w formacie E.164 (+48 i 9 cyfr planu krajowego)
SELECT
    id,
    imie_nazwisko,
    telefon
FROM klienci
WHERE telefon IS NULL
   OR telefon !~ '^\+48[1-9][0-9]{8}$'
   OR SUBSTR(telefon, 4, 9) IN ('111111111', '222222222', '555555555', '999999999', '123456789');

-- R07: Ważność daty urodzenia (przedział: od 120 lat wstecz do daty dzisiejszej)
SELECT
    id,
    imie_nazwisko,
    data_urodzenia
FROM klienci
WHERE data_urodzenia IS NULL
   OR data_urodzenia > CURRENT_DATE
   OR data_urodzenia < (CURRENT_DATE - INTERVAL '120 years');

-- R08: Ważność zakresu liczbowego (rabat 0-50%) oraz słownika statusów
SELECT
    id,
    imie_nazwisko,
    status_klienta,
    rabat_proc
FROM klienci
WHERE rabat_proc IS NULL
   OR rabat_proc NOT BETWEEN 0 AND 50
   OR status_klienta IS NULL
   OR status_klienta NOT IN ('AKTYWNY', 'ZAWIESZONY', 'ZAMKNIETY');

-- R09: Duplikaty e-maila po normalizacji (wielkość liter, spacje) oraz puste e-maile
-- Pusty adres nie może być kluczem, więc w pomiarze liczymy go jako błąd (patrz scorecard).
SELECT
    id,
    imie_nazwisko,
    nazwa_firmy,
    email,
    LOWER(TRIM(email)) AS email_znormalizowany,
    COUNT(*) OVER (PARTITION BY LOWER(TRIM(email))) AS liczba_wystapien
FROM klienci
WHERE email IS NULL
   OR TRIM(email) = ''
   OR LOWER(TRIM(email)) IN (
       SELECT LOWER(TRIM(email))
       FROM klienci
       WHERE email IS NOT NULL AND TRIM(email) <> ''
       GROUP BY LOWER(TRIM(email))
       HAVING COUNT(*) > 1
   )
ORDER BY id;

-- R10: Wykrycie duplikatów encji (ta sama osoba: znormalizowane imię i nazwisko + data urodzenia)
SELECT
    id,
    typ_klienta,
    imie_nazwisko,
    data_urodzenia,
    email,
    telefon,
    COUNT(*) OVER (
        PARTITION BY LOWER(TRIM(imie_nazwisko)), data_urodzenia
    ) AS liczba_kont_osoby
FROM klienci
WHERE (LOWER(TRIM(imie_nazwisko)), data_urodzenia) IN (
    SELECT LOWER(TRIM(imie_nazwisko)), data_urodzenia
    FROM klienci
    WHERE imie_nazwisko IS NOT NULL AND data_urodzenia IS NOT NULL
    GROUP BY LOWER(TRIM(imie_nazwisko)), data_urodzenia
    HAVING COUNT(*) > 1
)
ORDER BY LOWER(TRIM(imie_nazwisko)), id;

-- R11: Spójność wewnątrz rekordu (zgodność Kod pocztowy <-> Miasto wg PNA oraz porządek dat)
SELECT
    k.id,
    k.imie_nazwisko,
    k.kod_pocztowy,
    k.miasto AS miasto_w_rekordzie,
    p.miasto AS miasto_wg_pna,
    k.data_rejestracji,
    k.data_ostatniego_zakupu,
    CASE
        WHEN k.data_rejestracji > k.data_ostatniego_zakupu
            THEN 'Niespójność dat: rejestracja późniejsza niż ostatni zakup'
        WHEN p.kod_pocztowy IS NULL
            THEN 'Brak kodu w słowniku PNA (nie można potwierdzić miasta)'
        WHEN LOWER(TRIM(k.miasto)) <> LOWER(TRIM(p.miasto))
            THEN 'Niespójność geograficzna: kod pocztowy nie pasuje do miasta'
    END AS typ_niespojnosci
FROM klienci k
LEFT JOIN slownik_pna p ON k.kod_pocztowy = p.kod_pocztowy
WHERE k.data_rejestracji > k.data_ostatniego_zakupu
   OR p.kod_pocztowy IS NULL
   OR LOWER(TRIM(k.miasto)) <> LOWER(TRIM(p.miasto));

-- R12: Spójność między tabelami — nieaktywny klient (ZAMKNIETY) z otwartym zamówieniem
SELECT
    k.id AS klient_id,
    k.nazwa_firmy,
    k.status_klienta,
    z.id_zamowienia,
    z.data_zamowienia,
    z.status_zamowienia,
    z.kwota_brutto
FROM klienci k
INNER JOIN zamowienia z ON k.id = z.klient_id
WHERE k.status_klienta = 'ZAMKNIETY'
  AND z.status_zamowienia IN ('NOWE', 'W_REALIZACJI');

-- ============================================================================
-- ZBIORCZY DATA QUALITY SCORECARD (12 REGUŁ + SEMAFOR 95% / 85%)
-- Dialekt: PostgreSQL
-- ============================================================================

WITH ocena_rekordow AS (
    SELECT
        k.id,
        k.typ_klienta,

        -- 1. KOMPLETNOŚĆ (2 reguły)
        CASE WHEN k.email IS NOT NULL AND TRIM(k.email) <> ''
              AND LOWER(TRIM(k.email)) NOT IN ('brak', 'nie podano', 'n/a', 'null', '-')
             THEN 1.0 ELSE 0.0 END AS r01_kompletnosc_email,

        CASE WHEN k.typ_klienta = 'B2B' THEN
            CASE WHEN k.nip IS NOT NULL AND TRIM(k.nip) <> ''
                  AND k.nazwa_firmy IS NOT NULL AND TRIM(k.nazwa_firmy) <> ''
                 THEN 1.0 ELSE 0.0 END
        ELSE NULL END AS r02_kompletnosc_b2b,

        -- 2. POPRAWNOŚĆ FORMATU (4 reguły)
        CASE WHEN k.typ_klienta = 'B2B' THEN
            CASE WHEN k.nip IS NOT NULL
                  AND k.nip ~ '^[1-9][0-9]{9}$'
                  AND (
                      (CAST(SUBSTR(k.nip, 1, 1) AS INTEGER) * 6 +
                       CAST(SUBSTR(k.nip, 2, 1) AS INTEGER) * 5 +
                       CAST(SUBSTR(k.nip, 3, 1) AS INTEGER) * 7 +
                       CAST(SUBSTR(k.nip, 4, 1) AS INTEGER) * 2 +
                       CAST(SUBSTR(k.nip, 5, 1) AS INTEGER) * 3 +
                       CAST(SUBSTR(k.nip, 6, 1) AS INTEGER) * 4 +
                       CAST(SUBSTR(k.nip, 7, 1) AS INTEGER) * 5 +
                       CAST(SUBSTR(k.nip, 8, 1) AS INTEGER) * 6 +
                       CAST(SUBSTR(k.nip, 9, 1) AS INTEGER) * 7) % 11
                  ) = CAST(SUBSTR(k.nip, 10, 1) AS INTEGER)
                 THEN 1.0 ELSE 0.0 END
        ELSE NULL END AS r03_poprawnosc_nip,

        CASE WHEN k.email IS NOT NULL
              AND LENGTH(TRIM(k.email)) <= 254
              AND k.email NOT LIKE '%..%'
              AND k.email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
             THEN 1.0 ELSE 0.0 END AS r04_format_email,

        CASE WHEN k.kod_pocztowy IS NOT NULL
              AND k.kod_pocztowy ~ '^[0-9]{2}-[0-9]{3}$'
              AND EXISTS (SELECT 1 FROM slownik_pna p WHERE p.kod_pocztowy = k.kod_pocztowy)
             THEN 1.0 ELSE 0.0 END AS r05_kod_pocztowy_pna,

        CASE WHEN k.telefon IS NOT NULL
              AND k.telefon ~ '^\+48[1-9][0-9]{8}$'
              AND SUBSTR(k.telefon, 4, 9) NOT IN ('111111111', '222222222', '555555555', '999999999', '123456789')
             THEN 1.0 ELSE 0.0 END AS r06_format_telefon,

        -- 3. WAŻNOŚĆ ZAKRESÓW I DAT (2 reguły)
        CASE WHEN k.data_urodzenia IS NOT NULL
              AND k.data_urodzenia >= CURRENT_DATE - INTERVAL '120 years'
              AND k.data_urodzenia <= CURRENT_DATE
             THEN 1.0 ELSE 0.0 END AS r07_waznosc_data_urodzenia,

        CASE WHEN k.rabat_proc BETWEEN 0 AND 50
              AND k.status_klienta IN ('AKTYWNY', 'ZAWIESZONY', 'ZAMKNIETY')
             THEN 1.0 ELSE 0.0 END AS r08_waznosc_zakres_slownik,

        -- 4. UNIKALNOŚĆ (2 reguły)
        CASE WHEN k.email IS NOT NULL AND TRIM(k.email) <> ''
              AND (SELECT COUNT(*) FROM klienci k2 WHERE LOWER(TRIM(k2.email)) = LOWER(TRIM(k.email))) = 1
             THEN 1.0 ELSE 0.0 END AS r09_unikalnosc_email,

        CASE WHEN (SELECT COUNT(*) FROM klienci k2
                   WHERE LOWER(TRIM(k2.imie_nazwisko)) = LOWER(TRIM(k.imie_nazwisko))
                     AND k2.data_urodzenia = k.data_urodzenia) = 1
             THEN 1.0 ELSE 0.0 END AS r10_unikalnosc_encji,

        -- 5. SPÓJNOŚĆ (2 reguły)
        CASE WHEN k.data_rejestracji <= k.data_ostatniego_zakupu
              AND EXISTS (
                  SELECT 1 FROM slownik_pna p
                  WHERE p.kod_pocztowy = k.kod_pocztowy
                    AND LOWER(TRIM(p.miasto)) = LOWER(TRIM(k.miasto))
              )
             THEN 1.0 ELSE 0.0 END AS r11_spojnosc_wewnatrz_rekordu,

        CASE WHEN NOT (
            k.status_klienta = 'ZAMKNIETY'
            AND EXISTS (
                SELECT 1 FROM zamowienia z
                WHERE z.klient_id = k.id
                  AND z.status_zamowienia IN ('NOWE', 'W_REALIZACJI')
            )
        ) THEN 1.0 ELSE 0.0 END AS r12_spojnosc_miedzy_tabelami
    FROM klienci k
),
metryki AS (
    SELECT 'R01' AS kod, 'Kompletność' AS wymiar, 'Kompletność e-mail (bez spacji/zaślepek)' AS regula, COUNT(r01_kompletnosc_email) AS badanych, SUM(r01_kompletnosc_email) AS poprawnych, ROUND(AVG(r01_kompletnosc_email) * 100, 1) AS wynik_proc, 99.0 AS prog_sla FROM ocena_rekordow
    UNION ALL
    SELECT 'R02', 'Kompletność', 'Kompletność warunkowa B2B (NIP i nazwa firmy)', COUNT(r02_kompletnosc_b2b), SUM(r02_kompletnosc_b2b), ROUND(AVG(r02_kompletnosc_b2b) * 100, 1), 100.0 FROM ocena_rekordow
    UNION ALL
    SELECT 'R03', 'Poprawność (format)', 'Walidacja NIP (10 cyfr + suma kontrolna mod 11)', COUNT(r03_poprawnosc_nip), SUM(r03_poprawnosc_nip), ROUND(AVG(r03_poprawnosc_nip) * 100, 1), 99.5 FROM ocena_rekordow
    UNION ALL
    SELECT 'R04', 'Poprawność (format)', 'Format adresu e-mail (składnia RFC 5321/5322)', COUNT(r04_format_email), SUM(r04_format_email), ROUND(AVG(r04_format_email) * 100, 1), 98.0 FROM ocena_rekordow
    UNION ALL
    SELECT 'R05', 'Poprawność (format)', 'Kod pocztowy (format NN-NNN + słownik PNA)', COUNT(r05_kod_pocztowy_pna), SUM(r05_kod_pocztowy_pna), ROUND(AVG(r05_kod_pocztowy_pna) * 100, 1), 98.0 FROM ocena_rekordow
    UNION ALL
    SELECT 'R06', 'Poprawność (format)', 'Numer telefonu (standard E.164: +48 i 9 cyfr)', COUNT(r06_format_telefon), SUM(r06_format_telefon), ROUND(AVG(r06_format_telefon) * 100, 1), 95.0 FROM ocena_rekordow
    UNION ALL
    SELECT 'R07', 'Ważność (zakresy i daty)', 'Ważność daty urodzenia (brak przyszłości i >120 lat)', COUNT(r07_waznosc_data_urodzenia), SUM(r07_waznosc_data_urodzenia), ROUND(AVG(r07_waznosc_data_urodzenia) * 100, 1), 99.0 FROM ocena_rekordow
    UNION ALL
    SELECT 'R08', 'Ważność (zakresy i daty)', 'Ważność rabatu (0-50%) i słownika statusów', COUNT(r08_waznosc_zakres_slownik), SUM(r08_waznosc_zakres_slownik), ROUND(AVG(r08_waznosc_zakres_slownik) * 100, 1), 100.0 FROM ocena_rekordow
    UNION ALL
    SELECT 'R09', 'Unikalność', 'Unikalność klucza (znormalizowany e-mail)', COUNT(r09_unikalnosc_email), SUM(r09_unikalnosc_email), ROUND(AVG(r09_unikalnosc_email) * 100, 1), 100.0 FROM ocena_rekordow
    UNION ALL
    SELECT 'R10', 'Unikalność', 'Unikalność encji (imię i nazwisko + data urodzenia)', COUNT(r10_unikalnosc_encji), SUM(r10_unikalnosc_encji), ROUND(AVG(r10_unikalnosc_encji) * 100, 1), 98.0 FROM ocena_rekordow
    UNION ALL
    SELECT 'R11', 'Spójność', 'Spójność rekordu (Kod PNA <-> Miasto oraz daty)', COUNT(r11_spojnosc_wewnatrz_rekordu), SUM(r11_spojnosc_wewnatrz_rekordu), ROUND(AVG(r11_spojnosc_wewnatrz_rekordu) * 100, 1), 98.0 FROM ocena_rekordow
    UNION ALL
    SELECT 'R12', 'Spójność', 'Spójność między tabelami (Status klienta a zamówienia)', COUNT(r12_spojnosc_miedzy_tabelami), SUM(r12_spojnosc_miedzy_tabelami), ROUND(AVG(r12_spojnosc_miedzy_tabelami) * 100, 1), 100.0 FROM ocena_rekordow
)
SELECT
    kod,
    wymiar,
    regula,
    CAST(poprawnych AS INTEGER) || '/' || badanych AS rekordy_ok,
    wynik_proc,
    CASE
        WHEN wynik_proc >= 95.0 THEN 'ZIELONY (>=95%)'
        WHEN wynik_proc >= 85.0 THEN 'ZOLTY (85-95%)'
        ELSE 'CZERWONY (<85%)'
    END AS semafor_scorecard,
    prog_sla AS docelowe_sla_proc,
    CASE
        WHEN wynik_proc >= prog_sla THEN 'SPEŁNIA SLA'
        ELSE 'PONIŻEJ SLA (-' || ROUND(prog_sla - wynik_proc, 1) || ' pp)'
    END AS status_sla
FROM metryki
ORDER BY kod;
