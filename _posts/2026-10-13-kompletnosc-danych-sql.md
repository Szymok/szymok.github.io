---
layout: post
title: "Kompletność danych w SQL: 5 zapytań do uruchomienia dziś"
date: 2026-10-13 08:00:00
description: "Jak zmierzyć jakość danych w SQL bez dodatkowych narzędzi: 5 zapytań do kompletności, od NULL-i po wynik z semaforem do scorecardu. Dane przykładowe do pobrania."
tags: [data-quality, sql, kompletnosc-danych, scorecard]
categories: [data-governance]
giscus_comments: true
toc:
  sidebar: left
---

Jak zmierzyć jakość danych, gdy nie masz narzędzia do Data Quality ani czasu na wdrożenie? Zacznij od **kompletności**, czyli od pytania, ile wymaganych wartości faktycznie jest w tabeli. Poniżej pięć zapytań SQL do pomiaru kompletności danych, które uruchomisz jeszcze dziś na własnej tabeli. Idą od najprostszego (NULL-e) do jednego wyniku z semaforem, który wstawisz do [arkusza Scorecard](/scorecard/). Kompletność to jeden z sześciu wymiarów opisanych w artykule [Wymiary jakości danych](/blog/2026/data-quality-dimensions/).

## Dane przykładowe

Tabela `klienci` ma 12 wymyślonych rekordów. Za wymagane uznajemy: nazwę, e-mail, telefon i miasto. NIP jest wymagany tylko dla firm. Wartości `NULL`, `''` (pusty tekst) i `' '` (spacja) są zapisane tak, jak w bazie.

| id | nazwa | typ | nip | email | telefon | miasto | data_utworzenia |
|---|---|---|---|---|---|---|---|
| 1 | Alfa Sp. z o.o. | firma | 7010000001 | biuro@alfa.example | 221234567 | Warszawa | 2025-01-10 |
| 2 | Beta SA | firma | NULL | kontakt@beta.example | +48 600 100 200 | Kraków | 2025-02-03 |
| 3 | Gamma | firma | `''` | info@gamma.example | NULL | Gdańsk | 2025-02-15 |
| 4 | Jan Kowalski | osoba | NULL | jan.k@example.com | 501 222 333 | Łódź | 2025-03-01 |
| 5 | Anna Nowak | osoba | NULL | n/d | 502 333 444 | NULL | 2025-03-09 |
| 6 | Delta Sp. z o.o. | firma | brak | - | `''` | Poznań | 2025-04-20 |
| 7 | Epsilon Sp. z o.o. | firma | 7010000003 | epsilon@epsilon.example | 123456789 | Rzeszów | 2025-04-28 |
| 8 | Anna Wiśniewska | osoba | NULL | a.wisniewska@example.com | `' '` | Wrocław | 2025-05-11 |
| 9 | Zeta Sp. z o.o. | firma | 7010000004 | zeta@zeta.example | 123456780 | Szczecin | 2025-06-02 |
| 10 | Eta | firma | --- | NULL | - | Lublin | 2025-07-14 |
| 11 | Piotr Zieliński | osoba | NULL | piotr.z@example.com | 503 444 555 | Katowice | 2025-08-30 |
| 12 | Theta SA | firma | 7010000007 | theta@theta.example | 224445566 | NULL | 2025-09-18 |

Cały skrypt (tabela, dane i wszystkie zapytania) pobierzesz tutaj: [kompletnosc-danych.sql](/assets/files/kompletnosc-danych.sql). Sprawdziłem go w SQLite. Zapytania używają standardowych funkcji, ale w PostgreSQL, MySQL czy SQL Server mogą wymagać drobnych zmian składni.

## 1. Ile jest NULL-i w kolumnie

`COUNT(kolumna)` liczy tylko wartości różne od `NULL`, więc iloraz z `COUNT(*)` daje odsetek wypełnienia.

```sql
SELECT COUNT(*)                                    AS wiersze,
       ROUND(100.0 * COUNT(nip)     / COUNT(*), 1) AS nip_proc,
       ROUND(100.0 * COUNT(email)   / COUNT(*), 1) AS email_proc,
       ROUND(100.0 * COUNT(telefon) / COUNT(*), 1) AS telefon_proc,
       ROUND(100.0 * COUNT(miasto)  / COUNT(*), 1) AS miasto_proc
FROM klienci;
```

| wiersze | nip_proc | email_proc | telefon_proc | miasto_proc |
|---|---|---|---|---|
| 12 | 58.3 | 91.7 | 91.7 | 83.3 |

E-mail i telefon wyglądają dobrze (91,7%). To pułapka, bo `NULL` nie jest jedynym sposobem, w jaki w bazie pojawia się brak.

## 2. Puste teksty i wartości zastępcze

W prawdziwych danych brak ma wiele postaci: pusty tekst, spacja, `n/d`, `-`, `brak`. Zanim je zliczysz, sprawdź, jakie wartości zastępcze faktycznie występują w kolumnie (najczęstsze bardzo krótkie wartości):

```sql
SELECT LOWER(TRIM(email)) AS wartosc, COUNT(*) AS ile
FROM klienci
WHERE email IS NOT NULL AND LENGTH(TRIM(email)) < 6
GROUP BY LOWER(TRIM(email))
ORDER BY ile DESC;
```

Wynik pokazuje `n/d` i `-`. Listę z własnej bazy wpisz do widoku, który oznacza każde pole jako wypełnione (1) albo nie (0):

```sql
CREATE VIEW klienci_oceny AS
SELECT id, typ, data_utworzenia,
       CASE WHEN LOWER(TRIM(COALESCE(nip,   ''))) IN ('', '-', '--', '---', 'n/d', 'n/a', 'brak') THEN 0 ELSE 1 END AS nip_ok,
       CASE WHEN LOWER(TRIM(COALESCE(email, ''))) IN ('', '-', '--', '---', 'n/d', 'n/a', 'brak') THEN 0 ELSE 1 END AS email_ok
       -- ... analogicznie dla nazwy, telefonu i miasta (pełny skrypt w pliku)
FROM klienci;
```

Ten sam pomiar na widoku (`SUM(email_ok)` zamiast `COUNT(email)` itd.) daje inne liczby:

| kolumna | tylko NULL | z wartościami zastępczymi |
|---|---|---|
| nip | 58,3% | **33,3%** |
| email | 91,7% | **75,0%** |
| telefon | 91,7% | **66,7%** |
| miasto | 83,3% | 83,3% |

Telefon spadł o 25 punktów procentowych. Ta różnica jest typowa: pomiar samych `NULL`-i zwykle zawyża kompletność, a odsetek zależy od tego, jak uczciwie zdefiniujesz brak.

## 3. Kompletność warunkowa

Nie każde pole jest wymagane zawsze. NIP dotyczy firm, osoby go nie mają, więc liczenie go dla całej tabeli zaniża wynik.

```sql
SELECT COUNT(*)                                 AS firmy,
       SUM(nip_ok)                              AS firmy_z_nip,
       ROUND(100.0 * SUM(nip_ok) / COUNT(*), 1) AS nip_proc_firmy
FROM klienci_oceny
WHERE typ = 'firma';
```

| firmy | firmy_z_nip | nip_proc_firmy |
|---|---|---|
| 8 | 4 | 50.0 |

Rzeczywista kompletność NIP wśród firm to 50%, a nie 33,3%. Reguła „NIP wymagany, gdy typ = firma" jest właśnie regułą jakości, którą ktoś musi zdefiniować i zaakceptować.

## 4. Trend w czasie

Jeden wynik nie mówi, czy problem trwa od zawsze, czy pojawił się po zmianie formularza lub integracji. Zapytanie grupuje rekordy według miesiąca utworzenia i liczy te, w których wszystkie pola wymagane są wypełnione:

```sql
SELECT SUBSTR(CAST(data_utworzenia AS VARCHAR(10)), 1, 7) AS miesiac,
       COUNT(*)                                           AS rekordy,
       SUM(CASE WHEN nazwa_ok = 1 AND email_ok = 1 AND telefon_ok = 1 AND miasto_ok = 1
                 AND (typ <> 'firma' OR nip_ok = 1) THEN 1 ELSE 0 END) AS kompletne
FROM klienci_oceny
GROUP BY SUBSTR(CAST(data_utworzenia AS VARCHAR(10)), 1, 7)
ORDER BY miesiac;
```

| miesiac | rekordy | kompletne |
|---|---|---|
| 2025-01 | 1 | 1 |
| 2025-02 | 2 | 0 |
| 2025-03 | 2 | 1 |
| 2025-04 | 2 | 1 |
| 2025-05 | 1 | 0 |
| 2025-06 | 1 | 1 |
| 2025-07 | 1 | 0 |
| 2025-08 | 1 | 1 |
| 2025-09 | 1 | 0 |

Na 12 rekordach to tylko ilustracja. Na prawdziwej tabeli taki szereg pozwala wskazać miesiąc, w którym kompletność spadła, i zapytać, co się wtedy zmieniło.

## 5. Jeden wynik do scorecardu

Na koniec dwa pomiary w jednym: odsetek wypełnionych pól wymaganych oraz semafor z progami z [arkusza Scorecard](/scorecard/) (zielony od 95%, żółty 85-95%, czerwony poniżej 85%).

```sql
WITH pola AS (
    SELECT id,
           4 + CASE WHEN typ = 'firma' THEN 1 ELSE 0 END AS wymagane,
           nazwa_ok + email_ok + telefon_ok + miasto_ok
             + CASE WHEN typ = 'firma' THEN nip_ok ELSE 0 END AS wypelnione
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
```

| kompletnosc_proc | semafor |
|---|---|
| 76.8 | czerwony |

43 z 56 wymaganych pól jest wypełnionych (76,8%). Surowsza miara, odsetek w pełni kompletnych rekordów, wynosi 5 z 12, czyli 41,7%. Która miara jest właściwa, zależy od tego, do czego dane służą. Dla wysyłki faktur liczy się komplet pól, dla statystyk wystarczy odsetek wypełnienia.

## Czego te zapytania nie powiedzą

- **Kompletne nie znaczy poprawne.** NIP `7010000001` jest wypełniony, ale nie wiadomo, czy ma poprawną sumę kontrolną. E-mail bez `@` też liczy się jako wypełniony. To już wymiary zgodności formatu i dokładności.
- **Lista pól wymaganych i progi to decyzja biznesowa**, nie analityka SQL. Kto ją zatwierdza, kto odpowiada za naprawę i jaki próg jest akceptowalny, to pytania z obszaru Data Governance. Bez właściciela danych wynik 76,8% jest tylko liczbą.
- **Dwa pomiary kompletności mogą się mocno różnić** (tu 76,8% i 41,7%). Zapisz, której używasz i dlaczego, żeby wynik dało się powtórzyć za kwartał.

## Co dalej

- Wpisz wynik do [arkusza Scorecard](/scorecard/) i porównaj z kolejnymi wymiarami.
- Nie masz bazy pod ręką, tylko plik CSV? Policz kompletność, unikalność i ważność w [narzędziu DQ Profiler](/narzedzia/profil-danych/). Działa w przeglądarce, a plik nie jest nigdzie wysyłany. Po ustawieniu tych samych pól wymaganych co wyżej (NIP tylko dla firm) dostaniesz te same liczby, a plik z przykładowymi danymi znajdziesz na stronie narzędzia.
- Sprawdź w [teście dojrzałości Data Quality](/dojrzalosc-dq/) (12 pytań, 5 minut), czy w firmie ktoś w ogóle odpowiada za takie pomiary.
- Jeśli wyniki Cię zaskoczyły i potrzebujesz pełnego pomiaru w sześciu wymiarach z planem naprawy, zobacz [audyt jakości danych](/audyt-data-quality/).
