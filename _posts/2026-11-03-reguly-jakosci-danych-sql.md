---
layout: post
title: "Reguły jakości danych: 12 przykładów z progami"
date: 2026-11-03 08:00:00
description: "12 reguł jakości danych gotowych do skopiowania: NIP, e-mail, daty, słowniki, unikalność. Każda z zapisem SQL, progiem akceptacji i sposobem naprawy."
tags: [data-quality, reguly-jakosci-danych, sql, walidacja-danych, scorecard]
categories: [data-governance]
giscus_comments: true
toc:
  sidebar: left
---

Szukasz gotowych **reguł jakości danych** z przykładami, które da się uruchomić na własnej tabeli? Poniżej jest 12 reguł w SQL: od kompletności, przez walidację NIP, e-maila i kodu pocztowego, po duplikaty i spójność między tabelami. Każda ma zapytanie, próg akceptacji i sposób naprawy. Na końcu wszystkie wyniki trafiają do jednego zapytania z semaforem, który wstawisz do [arkusza Scorecard](/scorecard/). Kompletność omówiłem wcześniej w [5 zapytaniach SQL do pomiaru kompletności](/blog/2026/kompletnosc-danych-sql/), więc tutaj idziemy krok dalej.

Dane są w całości syntetyczne. Całość (tabele, 20 rekordów, 12 reguł i zapytanie zbiorcze) pobierzesz jako [reguly-jakosci-danych.sql](/assets/files/reguly-jakosci-danych.sql). Skrypt uruchomiłem w PostgreSQL 16. Reguły R03–R06 używają operatora `~` (regex), a R07 działa na `INTERVAL`, więc w innych bazach wymagają zmian składni.

## Jak czytać reguły i progi

Reguły są pogrupowane w pięć kategorii. Dwie z nich dzielą wymiar **zgodności formatu (Validity)** z wpisu [Wymiary jakości danych](/blog/2026/data-quality-dimensions/), żeby łatwiej było zrobić z nich osobne wiersze scorecardu:

| Kategoria w tym wpisie            | Reguły  | Wymiar z wpisu o wymiarach  |
| --------------------------------- | ------- | --------------------------- |
| Kompletność                       | R01–R02 | Kompletność                 |
| Poprawność (format i algorytmy)   | R03–R06 | Zgodność formatu (Validity) |
| Ważność (zakresy, daty, słowniki) | R07–R08 | Zgodność formatu (Validity) |
| Unikalność                        | R09–R10 | Unikalność                  |
| Spójność                          | R11–R12 | Spójność                    |

„Ważność" oznacza tu poprawność zakresu i słownika, a nie to, czy dane się zestarzały (to wymiar Aktualność).

Progi są dwa i warto ich nie mylić:

- **Semafor scorecardu** jest jednakowy dla wszystkich reguł: zielony od 95%, żółty 85–95%, czerwony poniżej 85%. Służy do pierwszego pomiaru.
- **Docelowe SLA** ustawiasz osobno dla każdej reguły, zależnie od wagi biznesowej. Dla identyfikatorów podatkowych (NIP w B2B) to w tym wpisie 99,5%, dla formatu telefonu 95%. Takie same 99,5% pokazałem we wpisie o wymiarach jako próg akceptacji reguły „Każdy klient musi mieć poprawny NIP".

Przedstawione SLA to **przykłady**. O prawdziwych progach decyduje właściciel danych, nie autor zapytania.

## Dane testowe

Tabela `klienci` ma 20 rekordów (10 firm B2B i 10 klientów B2C), a do tego jest mały słownik `slownik_pna` (wycinek 15 kodów) i tabela `zamowienia`. W danych celowo siedzą błędy, które łapią kolejne reguły:

- `id = 6`: NIP `1234567890`. Suma ważona daje 230, a 230 mod 11 = 10, czyli taki NIP nie może istnieć.
- `id = 7`: NIP z błędną cyfrą kontrolną oraz kod pocztowy z Warszawy przy mieście Kraków.
- `id = 8`: firma bez NIP i bez nazwy.
- `id = 9`: duplikat `id = 1` (ten sam NIP, ta sama osoba, e-mail wielkimi literami).
- `id = 10`: NIP z myślnikami i zamówienie w realizacji dla klienta o statusie `ZAMKNIETY`.
- `id = 15`: e-mail złożony z samych spacji.
- `id = 16`: e-mail bez `@` i telefon `12345`.
- `id = 17`: kod pocztowy `79-100`, którego nie ma w słowniku, i telefon `+48000000000`.
- `id = 18`: data urodzenia z przyszłości i rejestracja późniejsza niż ostatni zakup.
- `id = 19`: rok urodzenia 1899, rabat 85% i status spoza słownika.
- `id = 20`: duplikat rozmyty `id = 11` i kod pocztowy bez myślnika.

## Kompletność

### R01: e-mail bez NULL, pustych tekstów i zaślepek

`email IS NOT NULL` nie wystarczy, bo formularze zapisują też spacje i zaślepki typu `brak`. Zapytanie przycina wartość i sprawdza listę zaślepek (uzupełnij ją o te z własnej bazy). **Wynik: 95,0% (19/20), błędny `id = 15`.** Semafor zielony, ale przy SLA 99% to za mało dla głównego kanału kontaktu. **Naprawa:** zamień zaślepki na `NULL` i dodaj walidację po `TRIM()` przy zapisie.

```sql
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
```

### R02: kompletność warunkowa, NIP i nazwa firmy dla B2B

Od klientów indywidualnych NIP nie wymagamy, od firm tak. Mianownikiem są więc tylko rekordy B2B (10), a nie cała tabela. **Wynik: 90,0% (9/10), błędny `id = 8`.** Semafor żółty, SLA 100%. **Naprawa:** ograniczenie `CHECK (typ_klienta <> 'B2B' OR (nip IS NOT NULL AND TRIM(nip) <> '' AND nazwa_firmy IS NOT NULL AND TRIM(nazwa_firmy) <> ''))` i uzupełnienie braków z rejestru (GUS, CEIDG).

```sql
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
```

## Poprawność: format i algorytmy

### R03: walidacja NIP w SQL

NIP ma 10 cyfr, a ostatnia jest cyfrą kontrolną. Mnożysz pierwsze dziewięć cyfr przez wagi `6, 5, 7, 2, 3, 4, 5, 6, 7`, sumujesz i dzielisz z resztą przez 11. Reszta musi równać się dziesiątej cyfrze. **Pułapka:** jeśli reszta wynosi 10, numer jest nieprawidłowy, bo nie da się jej zapisać jedną cyfrą. W algorytmie REGON reszta 10 zamienia się w 0, ale w NIP-ie tego robić nie wolno. W SQL wystarczy porównanie reszty z dziesiątą cyfrą, które takie numery odrzuci samo. Zapytanie pokazuje też powód błędu.

**Wynik: 60,0% (6/10), błędne `id = 6, 7, 8, 10`.** Semafor czerwony przy SLA 99,5%. **Naprawa w dwóch krokach:** usuń z pola znaki niebędące cyframi (`REGEXP_REPLACE(nip, '[^0-9]', '', 'g')`), co naprawi `id = 10`. Rekordy z błędną cyfrą kontrolną (`id = 6, 7`) sprawdź w rejestrze po nazwie podmiotu.

```sql
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
```

### R04: składnia adresu e-mail

Reguła łapie brak `@`, spacje, podwójne kropki i adresy dłuższe niż 254 znaki. Nie próbuj kopiować wielolinijkowego regexa z pełnej gramatyki RFC 5322, bo i tak nie powie Ci, czy skrzynka istnieje. **Wynik: 90,0% (18/20), błędne `id = 15, 16`.** Semafor żółty, SLA 98%. **Naprawa:** `LOWER(TRIM(email))`, poprawa literówek w popularnych domenach, a istnienie skrzynki potwierdzaj w procesie (double opt-in, o czym niżej).

```sql
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
```

### R05: kod pocztowy, format i słownik PNA

Regex `NN-NNN` przepuszcza 100 000 kombinacji, a w użyciu jest około 20 tysięcy kodów z Oficjalnego Spisu PNA Poczty Polskiej. Dlatego format sprawdzamy razem ze słownikiem. W przykładzie to wycinek 15 kodów, w produkcji załaduj pełny spis. **Wynik: 90,0% (18/20), błędne `id = 17, 20`:** `79-100` ma dobry format, ale nie ma go w słowniku, a `90001` nie ma myślnika. Semafor żółty, SLA 98%. **Naprawa:** wstaw brakujący myślnik (`SUBSTR(kod_pocztowy, 1, 2) || '-' || SUBSTR(kod_pocztowy, 3, 3)`), a resztę przypisz ponownie po miejscowości i ulicy.

```sql
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
```

### R06: numer telefonu (E.164, +48)

Polskie numery mają 9 cyfr, pierwsza nie jest zerem. Regex sprawdza też zapis `+48` i odrzuca oczywiste numery fikcyjne. **Wynik: 90,0% (18/20), błędne `id = 16, 17`.** Semafor żółty, SLA 95% (dane pomocnicze). **Naprawa:** w ETL usuń spacje i myślniki, zamień `0048` na `+48`, dopisz `+48` do 9-cyfrowych numerów, a numery fikcyjne wyczyść do `NULL`.

```sql
-- R06: Walidacja polskiego numeru telefonu w formacie E.164 (+48 i 9 cyfr planu krajowego)
SELECT
    id,
    imie_nazwisko,
    telefon
FROM klienci
WHERE telefon IS NULL
   OR telefon !~ '^\+48[1-9][0-9]{8}$'
   OR SUBSTR(telefon, 4, 9) IN ('111111111', '222222222', '555555555', '999999999', '123456789');
```

## Ważność: zakresy, daty, słowniki

### R07: data urodzenia

Reguła rozszerza przykład „data urodzenia nie jest z przyszłości" o dolną granicę, 120 lat wstecz. Łapie błąd roku (`2030-01-01`) i artefakty importu z arkuszy (`1899-01-01`). **Wynik: 90,0% (18/20), błędne `id = 18, 19`.** Semafor żółty, SLA 99%. **Naprawa:** wyczyść anomalie do `NULL`, żeby nie psuły analiz kohortowych, albo wylicz datę z PESEL-u, jeśli masz go zweryfikowany.

```sql
-- R07: Ważność daty urodzenia (przedział: od 120 lat wstecz do daty dzisiejszej)
SELECT
    id,
    imie_nazwisko,
    data_urodzenia
FROM klienci
WHERE data_urodzenia IS NULL
   OR data_urodzenia > CURRENT_DATE
   OR data_urodzenia < (CURRENT_DATE - INTERVAL '120 years');
```

### R08: zakres liczbowy i słownik

Rabat ma mieścić się w 0–50%, a status w zamkniętym słowniku. **Wynik: 95,0% (19/20), błędny `id = 19`.** Semafor zielony, ale przy SLA 100% to sygnał, że w schemacie brakuje więzów. **Naprawa:** `CHECK (rabat_proc BETWEEN 0 AND 50)`, klucz obcy do tabeli statusów, a „VIP" przenieś do osobnego atrybutu segmentacji.

```sql
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
```

## Unikalność

### R09: unikalność e-maila po normalizacji

Zwykłe `UNIQUE` nie widzi różnicy między `jan.kowalski@…` a `JAN.KOWALSKI@…`, więc normalizujemy wartość. Pusty e-mail nie może być kluczem, więc liczymy go jako błąd. **Wynik: 85,0% (17/20), błędne `id = 1, 9, 15`.** Semafor żółty, na samej granicy, SLA 100%. **Naprawa:** scal kartoteki `id = 1` i `id = 9`, a potem załóż `CREATE UNIQUE INDEX idx_klienci_email_uniq ON klienci (LOWER(TRIM(email)));`.

```sql
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
```

### R10: duplikaty encji (rozmyte)

Ta sama osoba często ma kilka kont z różnymi e-mailami. Reguła szuka jej po znormalizowanym imieniu i nazwisku oraz dacie urodzenia. Znajduje duplikat firmowy (`id = 1, 9`) i ukryty duplikat B2C (`id = 11, 20`). **Wynik: 80,0% (16/20), błędne `id = 1, 9, 11, 20`.** Semafor czerwony, SLA 98% (nie 100%, bo w dużej bazie dwie różne osoby mogą mieć to samo imię, nazwisko i datę urodzenia). **Naprawa:** przekaż pary do procesu łączenia i zbuduj złoty rekord klienta.

```sql
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
```

## Spójność

### R11: spójność w rekordzie (kod a miasto, kolejność dat)

Reguła porównuje miasto z rekordu z miastem przypisanym do kodu w słowniku oraz sprawdza, czy rejestracja nie jest późniejsza niż ostatni zakup. **Wynik: 80,0% (16/20), błędne `id = 7, 17, 18, 20`.** Semafor czerwony, SLA 98%. **Naprawa:** `CHECK (data_ostatniego_zakupu >= data_rejestracji)` i uzupełnianie miejscowości w formularzu na podstawie wybranego kodu.

```sql
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
```

### R12: spójność między tabelami

Klient `ZAMKNIETY` nie powinien mieć otwartych zamówień. W danych jest jedno, `id_zamowienia = 104` na 9 900 zł. **Wynik: 95,0% (19/20), błędny `id = 10`.** Semafor zielony, ale przy SLA 100% to pokazuje, że przy procesach finansowych jeden niespójny rekord wymaga reakcji mimo zielonego koloru. **Naprawa:** blokada na styku CRM–ERP i wyjaśnienie, czy to błąd statusu, czy zamówienia.

```sql
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
```

## Wszystkie reguły w jednym zapytaniu: scorecard z semaforem

Zapytanie zbiorcze liczy każdą regułę na rekord (1 albo 0), a potem zamienia wyniki w tabelę z semaforem i porównaniem z SLA. Cały kod jest w [pobranym skrypcie](/assets/files/reguly-jakosci-danych.sql). Na danych testowych wynik wygląda tak:

| Reguła                  | Wymiar      | Wynik         | Semafor  | SLA   | Błędne `id`   |
| ----------------------- | ----------- | ------------- | -------- | ----- | ------------- |
| R01 e-mail niepusty     | Kompletność | 95,0% (19/20) | zielony  | 99,0% | 15            |
| R02 NIP i nazwa dla B2B | Kompletność | 90,0% (9/10)  | żółty    | 100%  | 8             |
| R03 NIP, suma kontrolna | Poprawność  | 60,0% (6/10)  | czerwony | 99,5% | 6, 7, 8, 10   |
| R04 format e-mail       | Poprawność  | 90,0% (18/20) | żółty    | 98,0% | 15, 16        |
| R05 kod pocztowy + PNA  | Poprawność  | 90,0% (18/20) | żółty    | 98,0% | 17, 20        |
| R06 telefon E.164       | Poprawność  | 90,0% (18/20) | żółty    | 95,0% | 16, 17        |
| R07 data urodzenia      | Ważność     | 90,0% (18/20) | żółty    | 99,0% | 18, 19        |
| R08 rabat i status      | Ważność     | 95,0% (19/20) | zielony  | 100%  | 19            |
| R09 unikalny e-mail     | Unikalność  | 85,0% (17/20) | żółty    | 100%  | 1, 9, 15      |
| R10 duplikaty encji     | Unikalność  | 80,0% (16/20) | czerwony | 98,0% | 1, 9, 11, 20  |
| R11 spójność rekordu    | Spójność    | 80,0% (16/20) | czerwony | 98,0% | 7, 17, 18, 20 |
| R12 spójność tabel      | Spójność    | 95,0% (19/20) | zielony  | 100%  | 10            |

Łącznie 193 poprawne wyniki na 220 sprawdzeń to **87,7%**, czyli semafor żółty. Trzy reguły są zielone, sześć żółtych i trzy czerwone. Zwróć uwagę, że **żadna reguła nie spełnia swojego SLA**, nawet te zielone. Semafor mówi, jak jest źle, a SLA mówi, czy to wystarcza.

Od czego zacząć naprawy? Od czerwonych: R03 (błędne NIP-y blokują faktury w KSeF), R10 (duplikaty zawyżają przychody i dublują kampanie) i R11 (niespójny adres to zwroty korespondencji).

## Gdzie kończy się SQL

Wszystkie 12 reguł sprawdza poprawność formalną. Mówią Ci, że dane **wyglądają** dobrze, a nie że są prawdziwe:

- **NIP** z poprawną sumą kontrolną może nigdy nie zostać nadany albo należeć do innej firmy. Istnienie podmiotu potwierdzisz w rejestrach (Biała Lista VAT, GUS, CEIDG, KRS, VIES).
- **Kod pocztowy** z dobrego słownika może nie pasować do ulicy. To już dane adresowe z pełnego spisu PNA.
- **E-mail** `jan.kowalski@nieistniejaca-firma.pl` przejdzie każdy regex. Domenę sprawdzisz zapytaniem DNS o rekord MX, a skrzynkę potwierdzi dopiero kliknięcie linku w procesie double opt-in. Sondowanie serwera SMTP (`RCPT TO`) bywa zawodne, bo serwery typu catch-all potwierdzają każdy adres.

To granica między wymiarem poprawności a dokładności (Accuracy). SQL zrobi pierwszą selekcję, a resztę musi zrobić proces.

## Czego te reguły nie rozstrzygną

- **Progi i SLA to decyzja biznesowa.** Kto je zatwierdza, kto naprawia i w jakim terminie, to pytania o Data Governance. Bez właściciela danych wynik 87,7% jest tylko liczbą.
- **Reguła bez naprawy niczego nie zmienia.** Każdy z powyższych wyników powinien mieć właściciela i termin poprawy.
- **Reguły starzeją się.** Słownik PNA, lista zaślepek i próg SLA wymagają przeglądu, najlepiej razem z wersjonowaniem reguł w repozytorium.

## Co dalej

- Wpisz wyniki do [arkusza Scorecard](/scorecard/) i ustaw SLA dla własnych reguł.
- Masz tylko plik CSV zamiast bazy? Policz kompletność, unikalność i zakresy w [narzędziu DQ Profiler](/narzedzia/profil-danych/). Działa w przeglądarce, a plik nie jest nigdzie wysyłany.
- Sprawdź w [teście dojrzałości Data Quality](/dojrzalosc-dq/) (12 pytań, 5 minut), czy ktoś w firmie odpowiada za takie pomiary.
- Potrzebujesz pełnego pomiaru w sześciu wymiarach z listą reguł, progami i planem naprawy? To rezultat [audytu jakości danych](/audyt-data-quality/).
