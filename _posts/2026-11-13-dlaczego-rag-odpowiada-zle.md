---
layout: post
title: "Dlaczego RAG odpowiada źle: jakość danych w bazie wiedzy"
date: 2026-11-13 08:00:00
description: "Jakość danych RAG decyduje o odpowiedziach AI. 12 reguł SQL w PostgreSQL 16 wykrywa duplikaty, stare wersje i puste fragmenty w bazie wiedzy."
tags: [data-quality, ai, rag, sql, jakosc-danych]
categories: [data-governance]
giscus_comments: true
toc:
  sidebar: left
---

Czatbot firmy podaje klientowi 30 dni na zwrot, a obowiązuje 14. Albo obiecuje pracownikowi 4500 zł dziennie za prąd przy pracy zdalnej. Pierwszy odruch to wymiana modelu albo przepisanie promptu, ale często problem leży w danych. Chodzi o **jakość danych RAG**: duplikaty, stare wersje, brakujące metadane i puste fragmenty w bazie wiedzy, z której model czerpie odpowiedzi. Poniżej pokazuję, jak zmierzyć ją zwykłym SQL-em: 12 reguł na syntetycznej bazie wiedzy fikcyjnej firmy, z progami semafora i zapytaniem, którego wynik wstawisz do [arkusza Scorecard](/scorecard/). To ten sam sposób myślenia, co we wpisach o [wymiarach jakości danych](/blog/2026/data-quality-dimensions/) i [regułach jakości danych w SQL](/blog/2026/reguly-jakosci-danych-sql/).

Cały skrypt (tabele, 30 dokumentów, 18 fragmentów, 12 reguł i zapytanie zbiorcze) pobierzesz jako [rag-jakosc-danych.sql](/assets/files/rag-jakosc-danych.sql). Uruchomiłem go w PostgreSQL 16 z rozszerzeniem `pg_trgm` (`CREATE EXTENSION pg_trgm`). Dane są wymyślone, a adresy e-mail mają domenę `.example`. Reguły oznaczyłem K01–K12 (K jak korpus), żeby nie mylić ich z R01–R12 z wpisu o regułach dla tabeli klientów.

## Dlaczego RAG daje złe odpowiedzi

System RAG działa w trzech krokach: dokumenty trafiają do indeksu, wyszukiwarka wybiera pasujące fragmenty, a model generuje odpowiedź na ich podstawie. Błąd z pierwszego kroku nie znika w następnych. Model dostaje to, co znalazła wyszukiwarka, nawet jeśli to duplikat, stara wersja albo pusty fragment.

Barnett i współautorzy opisali siedem punktów awarii przy budowie systemów RAG ([arXiv:2401.05856](https://arxiv.org/abs/2401.05856)). Cztery pierwsze to brak właściwej treści w bazie (FP1), dokument poza najlepszymi wynikami (FP2), dokument pobrany, ale pominięty w kontekście (FP3) i odpowiedź obecna w kontekście, ale niewyłuskana (FP4). Moim zdaniem to właśnie te cztery są najbardziej wrażliwe na stan bazy wiedzy. Pozostałe trzy (zły format odpowiedzi, nietrafiony poziom szczegółowości, odpowiedź niepełna) zależą bardziej od promptu i modelu.

Trzy kolejne prace tłumaczą, dlaczego model sam sobie z kiepskimi danymi nie poradzi:

- Chen i współautorzy ([arXiv:2309.01431](https://arxiv.org/abs/2309.01431)) badali m.in. odporność modeli na fałszywe informacje w pobranych dokumentach i odmowę odpowiedzi, gdy brak danych. Modele radziły sobie z tym wyraźnie słabo.
- Liu i współautorzy ([arXiv:2307.03172](https://arxiv.org/abs/2307.03172)) pokazali, że modele gorzej wykorzystują informację z środka długiego kontekstu niż z jego początku i końca (efekt „lost in the middle”).
- Ouyang i współautorzy ([arXiv:2503.04800](https://arxiv.org/abs/2503.04800)) zbadali wpływ przeterminowanych informacji na RAG. Stare dokumenty w bazie pogarszają odpowiedzi także wtedy, gdy aktualny dokument też trafił do kontekstu.

Z tego wynika praktyczny wniosek. Miara wierności kontekstowi (faithfulness) z frameworku RAGAS ([arXiv:2309.15217](https://arxiv.org/abs/2309.15217)) sprawdza, czy odpowiedź wynika z pobranych fragmentów, a nie czy same fragmenty są prawdziwe i aktualne. Odpowiedź wierna błędnemu dokumentowi dostanie wysoką ocenę. Tej luki nie zamknie ocena modelu, tylko kontrola danych.

## Jakość danych RAG w praktyce: sześć wymiarów w bazie wiedzy

Poniżej moje mapowanie sześciu wymiarów z wpisu o [wymiarach jakości danych](/blog/2026/data-quality-dimensions/) na bazę wiedzy dla AI. To moja interpretacja, nie klasyfikacja z literatury.

| Wymiar           | Jak wygląda w bazie wiedzy                                                                    | Reguły   |
| ---------------- | --------------------------------------------------------------------------------------------- | -------- |
| Unikalność       | Duplikaty dokładne i zbliżone, np. ten sam regulamin z intranetu i z SharePointu              | K01, K02 |
| Aktualność       | Obowiązujące dokumenty po terminie ważności, stare dokumenty bez daty przeglądu               | K03, K04 |
| Spójność         | Dwie wersje tego samego dokumentu jako obowiązujące, daty niezgodne ze sobą, sprzeczne treści | K05, K06 |
| Kompletność      | Brak właściciela i kategorii, dokument bez żadnego fragmentu w indeksie                       | K07, K08 |
| Zgodność formatu | Puste i za krótkie fragmenty, błędny format e-maila i numeru wersji                           | K09, K10 |
| Dokładność       | Skrót niezgodny z treścią, artefakty OCR, nierozwiązane placeholdery                          | K11, K12 |

Przy dokładności SQL sprawdzi tylko to, co techniczne. Czy treść jest prawdziwa, rozstrzyga człowiek (o tym w sekcji o granicach SQL), więc K11 i K12 to przybliżenie.

## Dane testowe

Fikcyjna firma NordVist Logistyka ma w tabeli `dokumenty` 30 dokumentów (procedury, regulaminy, instrukcje), a w tabeli `fragmenty` 18 fragmentów przekazanych do indeksu. Celowo zaszyłem w nich błędy:

- **Unikalność:** `id = 5` i `19` to kopie dokładne `4` i `18`, a `id = 7` i `21` to kopie `6` i `20` z jednym zmienionym słowem.
- **Aktualność:** `id = 8`, `9`, `22` są obowiązujące po terminie ważności, a `id = 23` jest sprzed ponad 3 lat i nie ma daty ważności.
- **Spójność:** `id = 10` i `11` to dwie wersje regulaminu zwrotów, obie obowiązujące (14 vs 30 dni), a `id = 24` ma ważność wcześniejszą niż publikacja.
- **Kompletność:** `id = 14` bez właściciela, `15` z właścicielem z samych spacji, `25` bez kategorii, `26` obowiązujący, ale bez fragmentów.
- **Zgodność formatu:** `id = 16` ma e-mail z `#` i wersję `wersja_2.0`, a fragmenty `4`, `9`, `15` są puste, to sam nagłówek i sama stopka strony.
- **Dokładność:** `id = 17` i `28` mają skrót niezgodny z treścią, `29` nierozwiązany `{{LIMIT_NOCLEGU_PLN}}`, a `30` artefakt `[BŁĄD_OCR]`.

Trzy przypadki są poza zasięgiem SQL i wrócą w sekcji o granicach: `id = 3` (ekwiwalent 4500 PLN dziennie zamiast 4,50) oraz `id = 12` i `13` (darmowa dostawa od 150 vs od 250 PLN). Jako datę odniesienia dla reguł aktualności przyjąłem 2026-11-11, żeby wynik dało się powtórzyć. W produkcji zamień ją na `CURRENT_DATE`.

## 12 reguł jakości danych bazy wiedzy

Progi semafora jak w Scorecardzie: zielony od 95%, żółty 85–95%, czerwony poniżej 85%. Procenty obcinam (`TRUNC`), a nie zaokrąglam, żeby wynik nie wyglądał lepiej niż jest: 29/30 to 96,66%, nie 96,67%. SLA przy regułach to przykłady do uzgodnienia z właścicielem bazy wiedzy.

### K01: duplikaty dokładne

Reguła porównuje skrót `hash_tresci` ze skrótami starszych dokumentów (niższe `id`). Łapie ten sam plik załadowany z kilku repozytoriów, np. z intranetu i z SharePointu. **Wynik: 93,33% (28/30), błędne `id = 5, 19`.** Semafor żółty, przykładowe SLA 98%. **Naprawa:** usuń oba dokumenty z rejestru i z indeksu, potem dodaj `UNIQUE (hash_tresci)`.

```sql
-- K01: Brak duplikatów dokładnych (hash_tresci)
SELECT
    d1.id AS id_duplikatu,
    d2.id AS id_oryginalu,
    d1.tytul,
    d1.status,
    d1.zrodlo,
    d1.hash_tresci
FROM dokumenty d1
JOIN dokumenty d2
  ON d1.hash_tresci = d2.hash_tresci
 AND d2.id < d1.id
ORDER BY d1.id;
```

### K02: duplikaty zbliżone (pg_trgm)

Skrót MD5 nie widzi kopii z jednym zmienionym słowem. Rozszerzenie `pg_trgm` mierzy podobieństwo tekstu funkcją `similarity()`, a próg 0,70 wyłapuje kopie z drobną korektą. Dokumenty `id = 7` i `21` różnią się od `6` i `20` jednym słowem („zespoły” na „komisje”, „weryfikuje” na „sprawdza”), a ich podobieństwo to 0,8955 i 0,8707. **Wynik: 93,33% (28/30), błędne `id = 7, 21`.** Żółty, SLA 95%. **Naprawa:** właściciel przegląda pary, scala zmiany do jednej wersji i usuwa robocze klony z indeksowania.

```sql
-- K02: Brak duplikatów zbliżonych (pg_trgm, similarity >= 0.70)
SELECT
    d1.id AS id_duplikatu_zblizonego,
    d2.id AS id_wzorca,
    d1.tytul AS tytul_duplikatu,
    d2.tytul AS tytul_wzorca,
    ROUND(similarity(d1.tresc, d2.tresc)::numeric, 4) AS podobienstwo_trgm
FROM dokumenty d1
JOIN dokumenty d2
  ON d2.id < d1.id
 AND d1.tresc <> d2.tresc
 AND similarity(d1.tresc, d2.tresc) >= 0.70
ORDER BY d1.id;
```

### K03: przeterminowane dokumenty obowiązujące

Dokument ze statusem `obowiazujacy` nie powinien mieć przekroczonej daty ważności. To najprostszy sposób, żeby stare cenniki i procedury nie konkurowały z aktualnymi. **Wynik: 90,00% (27/30), błędne `id = 8, 9, 22`.** Żółty, SLA 98%. **Naprawa:** zmień status na `archiwalny` i usuń fragmenty z aktywnego indeksu albo odnów datę ważności z właścicielem.

```sql
-- K03: Brak przeterminowanych dokumentów obowiązujących
SELECT
    id,
    tytul,
    wersja,
    status,
    data_publikacji,
    data_waznosci,
    ('2026-11-11'::date - data_waznosci) AS dni_po_terminie
FROM dokumenty
WHERE status = 'obowiazujacy'
  AND data_waznosci IS NOT NULL
  AND data_waznosci < '2026-11-11'::date
ORDER BY id;
```

### K04: stare dokumenty bez daty ważności

Obowiązujące dokumenty bez daty ważności mają „wieczne życie”. Reguła szuka takich, opublikowanych ponad 3 lata przed datą odniesienia. **Wynik: 96,66% (29/30), błędny `id = 23`.** Zielony, SLA 95% spełnione. **Naprawa:** wymagaj `data_waznosci` dla każdego obowiązującego dokumentu, np. do 24 lub 36 miesięcy od publikacji.

```sql
-- K04: Data ważności dla dokumentów obowiązujących starszych niż 3 lata
SELECT
    id,
    tytul,
    wersja,
    status,
    data_publikacji,
    data_waznosci,
    wlasciciel
FROM dokumenty
WHERE status = 'obowiazujacy'
  AND data_publikacji < ('2026-11-11'::date - INTERVAL '3 years')::date
  AND data_waznosci IS NULL
ORDER BY id;
```

### K05: jedna wersja obowiązująca pod jednym tytułem

`id = 10` (v1.0, 14 dni) i `id = 11` (v2.0, 30 dni) mają ten sam tytuł i oba status `obowiazujacy`, więc wyszukiwarka może podać modelowi obie wersje naraz. **Wynik: 93,33% (28/30), błędne `id = 10, 11`.** Żółty, SLA 100%. **Naprawa:** zarchiwizuj v1.0, usuń jej fragment z indeksu i załóż indeks częściowy: `CREATE UNIQUE INDEX idx_unikalny_obowiazujacy_tytul ON dokumenty (tytul) WHERE status = 'obowiazujacy';`.

```sql
-- K05: Jedna obowiązująca wersja dokumentu o danym tytule
SELECT
    d.id,
    d.tytul,
    d.wersja,
    d.status,
    d.data_publikacji,
    d.tresc
FROM dokumenty d
WHERE d.status = 'obowiazujacy'
  AND EXISTS (
      SELECT 1
      FROM dokumenty d2
      WHERE d2.tytul = d.tytul
        AND d2.status = 'obowiazujacy'
        AND d2.id <> d.id
  )
ORDER BY d.tytul, d.id;
```

### K06: spójność dat

Data ważności nie może być wcześniejsza niż data publikacji. **Wynik: 96,66% (29/30), błędny `id = 24`** (publikacja 2026-03-15, ważność 2025-03-15). Zielony, ale SLA 100% jest naruszone. **Naprawa:** popraw datę i dodaj `CHECK (data_waznosci IS NULL OR data_waznosci >= data_publikacji)`.

```sql
-- K06: Spójność dat (data_waznosci >= data_publikacji)
SELECT
    id,
    tytul,
    wersja,
    status,
    data_publikacji,
    data_waznosci
FROM dokumenty
WHERE data_waznosci IS NOT NULL
  AND data_waznosci < data_publikacji
ORDER BY id;
```

### K07: kompletność metadanych

Właściciel i kategoria muszą być wypełnione, także gdy pole zawiera same spacje (`btrim`). Bez nich nie da się zawęzić wyszukiwania metadanymi ani ustalić, kto odpowiada za przegląd. **Wynik: 90,00% (27/30), błędne `id = 14, 15, 25`** (NULL, same spacje, brak kategorii). Żółty, SLA 95%. **Naprawa:** uzupełnij z rejestru właścicieli procesów i dodaj `NOT NULL` oraz `CHECK (btrim(wlasciciel) <> '' AND btrim(kategoria) <> '')`.

```sql
-- K07: Wypełniony właściciel i kategoria
SELECT
    id,
    tytul,
    status,
    wlasciciel,
    kategoria
FROM dokumenty
WHERE wlasciciel IS NULL
   OR btrim(wlasciciel) = ''
   OR kategoria IS NULL
   OR btrim(kategoria) = ''
ORDER BY id;
```

### K08: dokument obowiązujący ma fragmenty

Brak fragmentów to cicha awaria potoku indeksowania: dokument jest w rejestrze, ale wyszukiwarka go nie widzi (to FP1 z pracy Barnetta i współautorów). **Wynik: 96,66% (29/30), błędny `id = 26`** (procedura zgłaszania incydentów RODO). Zielony, SLA 100% naruszone. **Naprawa:** uruchom podział na fragmenty ponownie i dodaj test uzgadniający po każdym przebiegu indeksowania.

```sql
-- K08: Obowiązujący dokument ma fragmenty
SELECT
    d.id,
    d.tytul,
    d.wersja,
    d.status,
    d.kategoria
FROM dokumenty d
LEFT JOIN fragmenty f
  ON f.dokument_id = d.id
WHERE d.status = 'obowiazujacy'
  AND f.id IS NULL
ORDER BY d.id;
```

### K09: minimalna długość fragmentu

Ta reguła działa na tabeli `fragmenty` (18 rekordów), nie na dokumentach. Szuka fragmentów krótszych niż 40 znaków po `btrim`: pustych, samych nagłówków i stopek stron, które powstają przy złym cięciu PDF-ów. Próg 40 znaków to przykład, dobierz własny. **Wynik: 83,33% (15/18), błędne fragmenty `id = 4, 9, 15`** (0, 33 i 13 znaków, z dokumentów 3, 10 i 20). To jedyna reguła czerwona. SLA 95%. **Naprawa:** oczyść dokumenty ze stopek i paginacji przed podziałem, łącz nagłówki z następującym akapitem i wygeneruj fragment dla `id = 3` jeszcze raz.

```sql
-- K09: Minimalna długość fragmentu (>= 40 znaków po btrim)
SELECT
    f.id AS id_fragmentu,
    f.dokument_id,
    f.nr,
    char_length(btrim(f.tresc)) AS dlugosc_po_btrim,
    f.tresc
FROM fragmenty f
WHERE char_length(btrim(f.tresc)) < 40
ORDER BY f.id;
```

### K10: format e-maila właściciela i numeru wersji

Adres e-mail właściciela i numer wersji muszą mieć poprawny format (`vX.Y`). Wzorzec e-maila zakłada tu domenę `.example`, w produkcji wpisz własną. **Wynik: 96,66% (29/30), błędny `id = 16`** (`bhp.admin#nordvist.example`, `wersja_2.0`). Zielony, SLA 95% spełnione. **Naprawa:** popraw wartości i dodaj `CHECK` z operatorem `~`.

```sql
-- K10: Format e-maila właściciela i numeru wersji
SELECT
    id,
    tytul,
    wersja,
    wlasciciel
FROM dokumenty
WHERE (
        wlasciciel IS NOT NULL
        AND btrim(wlasciciel) <> ''
        AND wlasciciel !~ '^[a-z0-9._%+-]+@[a-z0-9.-]+\.example$'
      )
   OR wersja !~ '^v[0-9]+\.[0-9]+$'
ORDER BY id;
```

### K11: skrót treści zgodny z md5

Zapisany skrót `hash_tresci` powinien równać się `md5(tresc)`. Niezgodność oznacza, że treść zmieniono bez przeliczenia skrótu, a więc prawdopodobnie także bez odświeżenia wektorów w indeksie, albo że skrót uszkodzono przy migracji. **Wynik: 93,33% (28/30), błędne `id = 17, 28`** (skróty same zera i same `f`). Żółty, SLA 100%. **Naprawa:** przelicz skrót, wymuś ponowne zindeksowanie i zamień kolumnę na wyliczaną: `hash_tresci TEXT GENERATED ALWAYS AS (md5(tresc)) STORED`.

```sql
-- K11: Skrót treści zgodny z md5(tresc)
SELECT
    id,
    tytul,
    wersja,
    status,
    hash_tresci AS zapisany_hash,
    md5(tresc) AS rzeczywisty_md5
FROM dokumenty
WHERE hash_tresci <> md5(tresc)
ORDER BY id;
```

### K12: artefakty OCR i placeholdery

Reguła szuka w treści nierozwiązanych znaczników szablonu (`{{...}}`), znacznika `[BŁĄD_OCR]` i znaku zastępczego Unicode U+FFFD. Model może przepisać taki znacznik do odpowiedzi albo zmyślić brakującą liczbę. **Wynik: 93,33% (28/30), błędne `id = 29, 30`.** Żółty, SLA 98%. **Naprawa:** podstaw właściwą wartość w `id = 29`, popraw skan `id = 30` i dodaj bramkę walidacyjną przed publikacją dokumentu do bazy wiedzy.

```sql
-- K12: Brak artefaktów OCR i placeholderów w treści
SELECT
    id,
    tytul,
    wersja,
    status,
    tresc
FROM dokumenty
WHERE tresc ~ '(\{\{.*\}\}|\[BŁĄD_OCR\]|\uFFFD)'
ORDER BY id;
```

## Wszystkie reguły w jednym zapytaniu: scorecard z semaforem

Zapytanie zbiorcze liczy każdą regułę, zamienia wynik w semafor i porównuje go z SLA. Cały kod jest w [pobranym skrypcie](/assets/files/rag-jakosc-danych.sql). Na danych testowych wynik wygląda tak:

| Reguła                      | Wymiar           | Wynik          | Semafor  | SLA  | Błędne `id` |
| --------------------------- | ---------------- | -------------- | -------- | ---- | ----------- |
| K01 duplikaty dokładne      | Unikalność       | 93,33% (28/30) | żółty    | 98%  | 5, 19       |
| K02 duplikaty zbliżone      | Unikalność       | 93,33% (28/30) | żółty    | 95%  | 7, 21       |
| K03 przeterminowane         | Aktualność       | 90,00% (27/30) | żółty    | 98%  | 8, 9, 22    |
| K04 brak daty ważności      | Aktualność       | 96,66% (29/30) | zielony  | 95%  | 23          |
| K05 kolizja wersji          | Spójność         | 93,33% (28/30) | żółty    | 100% | 10, 11      |
| K06 spójność dat            | Spójność         | 96,66% (29/30) | zielony  | 100% | 24          |
| K07 właściciel i kategoria  | Kompletność      | 90,00% (27/30) | żółty    | 95%  | 14, 15, 25  |
| K08 pokrycie fragmentami    | Kompletność      | 96,66% (29/30) | zielony  | 100% | 26          |
| K09 długość fragmentu       | Zgodność formatu | 83,33% (15/18) | czerwony | 95%  | 4, 9, 15    |
| K10 format e-maila i wersji | Zgodność formatu | 96,66% (29/30) | zielony  | 95%  | 16          |
| K11 skrót treści            | Dokładność       | 93,33% (28/30) | żółty    | 100% | 17, 28      |
| K12 artefakty OCR           | Dokładność       | 93,33% (28/30) | żółty    | 98%  | 29, 30      |

W podziale na wymiary wychodzi: Unikalność 56/60 (93,33%), Aktualność 56/60 (93,33%), Spójność 57/60 (95,00%), Kompletność 56/60 (93,33%), Zgodność formatu 44/48 (91,66%), Dokładność 56/60 (93,33%).

Razem jest 325 poprawnych wyników na 348 sprawdzeń (11 reguł po 30 dokumentów i K09 na 18 fragmentach): 325/348 = **93,39%**, semafor żółty. Uwaga na mianownik: K09 liczy fragmenty, a reszta dokumenty, więc to wynik ważony liczbą sprawdzeń, a nie średnia z procentów. Cztery reguły są zielone, siedem żółtych i jedna czerwona. Przykładowe SLA spełniają tylko K04 i K10.

Wynik 93,39% brzmi przyzwoicie, ale w RAG jeden błąd bywa wystarczający. K05 ma 28/30, a do złej odpowiedzi czatbota wystarczy jedna para sprzecznych wersji obowiązujących. Dlatego obok semafora trzymaj SLA per reguła, np. 100% dla kolizji wersji. Naprawy zacznij od tego, co najbardziej psuje wyszukiwanie: K09 (puste fragmenty), K05 (kolizja wersji) i K03 (przeterminowane dokumenty).

## Czego SQL nie rozstrzygnie

Naprawa wszystkich 23 trafień i wynik 100% w karcie nie sprawi, że RAG przestanie halucynować. W danych są trzy przypadki, które przechodzą wszystkie 12 reguł, a mimo to zepsują odpowiedzi:

- **Sprzeczność między różnymi dokumentami (`id = 12` i `13`).** Jeden dokument obiecuje darmową dostawę od 150 PLN, drugi tylko powyżej 250 PLN. Mają różne tytuły, aktualne daty i poprawne metadane, więc żadna reguła ich nie zgłasza. Podobieństwo trigramowe tych tekstów to 0,2895. Przegląd Xu i współautorów ([ACL Anthology](https://aclanthology.org/2024.emnlp-main.486.pdf)) nazywa takie sprzeczności między pobranymi dokumentami konfliktem między kontekstami (inter-context conflict), a zagadnienie rozwijają też Jin i współautorzy ([arXiv:2402.14409](https://arxiv.org/abs/2402.14409)).
- **Błąd merytoryczny w poprawnym dokumencie (`id = 3`).** Regulamin pracy zdalnej mówi o 4500 PLN dziennie zamiast 4,50. Dla bazy to tak samo poprawny tekst. Asystent HR bez wahania poda pracownikom absurdalną kwotę.
- **Sens fragmentów.** SQL sprawdzi, czy fragment ma 40 znaków, ale nie ocenia, czy zaimek na początku fragmentu nie stracił odniesienia, które zostało w poprzednim.

Granicę widać też w samych trigramach, bo `pg_trgm` mierzy podobieństwo znaków, a nie znaczenia. Sprawdziłem to na czterech przykładach (zdania w skrypcie):

| Przypadek                                                       | `similarity()` |
| --------------------------------------------------------------- | -------------- |
| Zmiana liczby: termin 14 dni kontra 30 dni (sprzeczne wartości) | 0,9326         |
| „przysługuje” kontra „nie przysługuje” (przeciwne znaczenie)    | 0,8214         |
| Parafraza o tym samym znaczeniu, inne słowa                     | 0,1121         |
| Dokumenty `id = 12` i `13` (150 kontra 250 PLN)                 | 0,2895         |

Wysokie podobieństwo nie znaczy więc zgodności treści, a niskie nie znaczy, że dokumenty mówią co innego.

| Warstwa kontroli    | Narzędzie                                         | Co wykrywa                                                                                        | Czego nie wykryje                                 |
| ------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| Deterministyczna    | SQL (`md5`, `btrim`, regex, `JOIN`, `CHECK`)      | Duplikaty dokładne, braki metadanych, daty, kolizje wersji, puste fragmenty, placeholdery, skróty | Parafrazy, sprzeczności, błędy faktograficzne     |
| Podobieństwo tekstu | `pg_trgm`                                         | Kopie z drobnymi zmianami                                                                         | Parafrazy i sprzeczne zdania o podobnym brzmieniu |
| Semantyczna         | Właściciel dokumentu (SME), model oceniający, NLI | Sprzeczności między dokumentami, błędne liczby w treści                                           | Nie zastępuje twardych więzów w bazie             |

Wniosek: SQL i `pg_trgm` odpowiadają za higienę korpusu, a sprzeczności i błędy faktograficzne wymagają przeglądu przez właściciela dokumentu i, jako wsparcia, automatycznego wykrywania sprzeczności na parach bliskich fragmentów. Tego drugiego tutaj nie mierzę.

## Co z tego wynika dla Data Quality / Data Governance

1. **Baza wektorowa nie powinna być systemem rekordowym.** Wrzucanie plików prosto do indeksu omija kontrolę jakości. Każdy dokument i fragment niech najpierw trafia do rejestru relacyjnego (tabele `dokumenty` i `fragmenty`), gdzie działają reguły K01–K12, a do indeksu idą tylko rekordy, które je przeszły i mają status `obowiazujacy`.
2. **Metadane to kontrakt, nie ozdoba.** Żaden dokument nie dostaje statusu `obowiazujacy` bez właściciela, kategorii, daty ważności i jednoznacznej wersji w obrębie tytułu. Dzięki temu wyszukiwarka może odfiltrować archiwalne i robocze dokumenty jeszcze przed porównaniem wektorów.
3. **Oddziel pomiar od przeglądu merytorycznego.** SQL mierzy higienę korpusu w sposób powtarzalny, a sprzeczności i błędne liczby ocenia właściciel dokumentu. Dodaj bazę wiedzy do firmowego [scorecardu](/scorecard/) i sprawdź w [teście dojrzałości Data Quality](/dojrzalosc-dq/), czy ktoś odpowiada za ten pomiar. Szerszy kontekst, czyli jak AI zmienia pracę z danymi, opisuje wpis [AI w Data Governance](/blog/2025/ai-models-dg/).

## Checklista: sześć wymiarów dla bazy wiedzy AI

- **Unikalność:** każdy dokument ma skrót treści, a duplikaty dokładne są usuwane przed indeksowaniem (K01). Kopie z drobnymi zmianami wykrywa `pg_trgm` (K02). W wyszukiwaniu hybrydowym wyniki z obu podsystemów są deduplikowane przed przekazaniem do kontekstu.
- **Aktualność:** żaden dokument obowiązujący nie jest po terminie ważności (K03), a starsze mają datę przeglądu (K04). Wycofane dokumenty znikają z aktywnego indeksu albo są w nim oznaczone jako archiwalne.
- **Spójność:** pod jednym tytułem jest jedna wersja obowiązująca (K05), a daty są ze sobą zgodne (K06). Pary bliskich fragmentów z różnych dokumentów przegląda człowiek lub model oceniający pod kątem sprzeczności.
- **Kompletność:** pola używane do filtrowania i nadzoru są wypełnione, bez NULL i samych spacji (K07). Po każdym przebiegu indeksowania test uzgadniający potwierdza, że każdy dokument obowiązujący ma fragmenty (K08).
- **Zgodność formatu:** podział na fragmenty odrzuca puste przebiegi, same nagłówki i stopki (K09). Tabele przed podziałem są zamieniane na format zachowujący nagłówki kolumn. Atrybuty zarządcze spełniają wzorce (K10).
- **Dokładność:** skrót treści zgadza się z `md5(tresc)` (K11), treść nie ma placeholderów ani artefaktów OCR (K12), a kluczowe liczby (stawki, terminy, limity) zatwierdza ekspert domenowy przed publikacją.

## Co dalej

- Wpisz wyniki do [arkusza Scorecard](/scorecard/) i ustaw własne SLA dla reguł bazy wiedzy.
- Masz tylko eksport metadanych dokumentów do pliku CSV? Policz kompletność, unikalność i zakresy w [narzędziu DQ Profiler](/narzedzia/profil-danych/). Działa w przeglądarce, a plik nie jest nigdzie wysyłany.
- Zobacz, jak mierzyć kompletność w SQL, we wpisie [Kompletność danych w SQL: 5 zapytań do uruchomienia dziś](/blog/2026/kompletnosc-danych-sql/).
- Potrzebujesz pełnego pomiaru w sześciu wymiarach z progami i planem naprawy? To rezultat [audytu jakości danych](/audyt-data-quality/).
