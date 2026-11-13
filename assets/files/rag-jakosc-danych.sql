-- ============================================================================
-- SKRYPT: SYNTETYCZNA BAZA WIEDZY RAG, 12 REGUŁ JAKOŚCI DANYCH (K01-K12), SCORECARD
-- Dialekt: PostgreSQL 16 (testowane na 16.15). Wymaga rozszerzenia pg_trgm.
-- Wszystkie dane są wymyślone. Adresy e-mail i URL-e mają domenę .example.
-- Podmiot fikcyjny: NordVist Logistyka Sp. z o.o. (domena: nordvist.example)
-- ============================================================================

-- Jawne włączenie rozszerzenia pg_trgm (wymagane dla pomiaru podobieństwa tekstu w regule K02)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

DROP TABLE IF EXISTS fragmenty;
DROP TABLE IF EXISTS dokumenty;

-- 1. Tabela główna korpusu dokumentów
CREATE TABLE dokumenty (
    id              INTEGER PRIMARY KEY,
    tytul           TEXT NOT NULL,
    tresc           TEXT NOT NULL,
    wersja          TEXT NOT NULL,
    status          TEXT NOT NULL CHECK (status IN ('obowiazujacy', 'archiwalny', 'projekt')),
    data_publikacji DATE NOT NULL,
    data_waznosci   DATE,
    wlasciciel      TEXT,
    kategoria       TEXT,
    zrodlo          TEXT NOT NULL,
    hash_tresci     TEXT NOT NULL
);

-- Indeks GIN oparty na trigramach dla przyspieszenia wyszukiwania near-duplicates
CREATE INDEX idx_dokumenty_tresc_trgm ON dokumenty USING GIN (tresc gin_trgm_ops);

-- 2. Tabela fragmentów (chunków) przekazywanych do indeksu wektorowego
CREATE TABLE fragmenty (
    id          INTEGER PRIMARY KEY,
    dokument_id INTEGER NOT NULL REFERENCES dokumenty(id) ON DELETE CASCADE,
    nr          INTEGER NOT NULL,
    tresc       TEXT NOT NULL,
    UNIQUE (dokument_id, nr)
);

-- ============================================================================
-- WSTAWIENIE 30 SYNTETYCZNYCH DOKUMENTÓW Z ZASZYTYMI BŁĘDAMI JAKOŚCI DANYCH
-- ============================================================================
-- Rozkład zaszytych błędów wykrywalnych przez SQL (po 3-4 na każdy z 6 wymiarów):
--   1. UNIKALNOŚĆ (4 błędy):
--      - id=5  (duplikat dokładny dokumentu id=4)
--      - id=19 (duplikat dokładny dokumentu id=18)
--      - id=7  (duplikat zbliżony dokumentu id=6, zmiana 1 słowa: "zespoły" -> "komisje")
--      - id=21 (duplikat zbliżony dokumentu id=20, zmiana 1 słowa: "weryfikuje" -> "sprawdza")
--   2. AKTUALNOŚĆ (4 błędy):
--      - id=8  (status 'obowiazujacy', mimo że data_waznosci minęła: 2024-12-31)
--      - id=9  (status 'obowiazujacy', mimo że data_waznosci minęła: 2025-06-30)
--      - id=22 (status 'obowiazujacy', mimo że data_waznosci minęła: 2026-01-31)
--      - id=23 (status 'obowiazujacy', opublikowany >3 lata temu: 2021-05-10, brak data_waznosci)
--   3. SPÓJNOŚĆ (3 błędy SQL + 2 dokumenty w konflikcie semantycznym poza zasięgiem SQL):
--      - id=10 i id=11 (dwie wersje v1.0 i v2.0 tego samego dokumentu oznaczone jednocześnie jako
--        'obowiazujacy' i podające sprzeczny termin zwrotu: 14 dni vs 30 dni)
--      - id=24 (niespójność chronologiczna: data_waznosci 2025-03-15 < data_publikacji 2026-03-15)
--      - [POZA SQL] id=12 i id=13 (dwa różne obowiązujące dokumenty z poprawnymi metadanymi,
--        ale sprzecznym progiem darmowej dostawy w treści: 150 PLN vs 250 PLN)
--   4. KOMPLETNOŚĆ (4 błędy):
--      - id=14 (brak właściciela: wlasciciel IS NULL)
--      - id=15 (ukryty brak właściciela: wlasciciel składa się z samych spacji '   ')
--      - id=25 (brak kategorii: kategoria IS NULL)
--      - id=26 (dokument 'obowiazujacy', który nie ma żadnego rekordu w tabeli `fragmenty`)
--   5. ZGODNOŚĆ FORMATU (4 błędy łącznie: 1 w `dokumenty` + 3 w `fragmenty`):
--      - dokumenty.id=16 (błędny format e-mail 'bhp.admin#nordvist.example' i wersji 'wersja_2.0')
--      - fragmenty.id=4  (pusty fragment złożony z samych spacji '   ' dla dokumentu id=3)
--      - fragmenty.id=9  (zbyt krótki fragment: 33 znaki, sam nagłówek dla dokumentu id=10)
--      - fragmenty.id=15 (zbyt krótki fragment: 13 znaków, sama stopka 'Strona 4 z 12' dla id=20)
--   6. DOKŁADNOŚĆ (4 błędy SQL + 1 błąd merytoryczny poza zasięgiem SQL):
--      - id=17 (fałszywy hash_tresci '0000...': treść zmieniona bez aktualizacji skrótu i indeksu)
--      - id=28 (fałszywy hash_tresci 'ffff...': uszkodzony skrót podczas migracji)
--      - id=29 (nierozwiązany placeholder szablonu '{{LIMIT_NOCLEGU_PLN}}' w treści dokumentu)
--      - id=30 (artefakt błędu skanowania '[BŁĄD_OCR]' w treści dokumentu)
--      - [POZA SQL] id=3 (wszystkie metadane i formaty poprawne, ale w treści wpisano absurdalną
--        kwotę ekwiwalentu 4500 PLN dziennie zamiast 4,50 PLN dziennie)
-- ============================================================================

INSERT INTO dokumenty (
    id, tytul, tresc, wersja, status, data_publikacji, data_waznosci, wlasciciel, kategoria, zrodlo, hash_tresci
) VALUES
-- id=1: Poprawny dokument referencyjny
(1, 'Polityka bezpieczeństwa informacji NordVist',
 'Każdy pracownik NordVist Logistyka Sp. z o.o. zobowiązany jest do szyfrowania dysków służbowych kluczem BitLocker oraz zmiany hasła domenowego co 90 dni.',
 'v2.1', 'obowiazujacy', '2026-01-15', '2027-12-31', 'bezpieczenstwo@nordvist.example', 'Bezpieczeństwo',
 'intranet.nordvist.example/polityki/pbi', md5('Każdy pracownik NordVist Logistyka Sp. z o.o. zobowiązany jest do szyfrowania dysków służbowych kluczem BitLocker oraz zmiany hasła domenowego co 90 dni.')),

-- id=2: Poprawny dokument referencyjny
(2, 'Procedura przyjęcia towaru do magazynu centralnego',
 'Operator wózka widłowego weryfikuje zgodność listy przewozowej z fizyczną liczbą palet EUR przed podpisaniem dokumentu WZ w systemie WMS.',
 'v1.4', 'obowiazujacy', '2025-11-20', '2027-06-30', 'magazyn@nordvist.example', 'Logistyka',
 'intranet.nordvist.example/wms/przyjecia', md5('Operator wózka widłowego weryfikuje zgodność listy przewozowej z fizyczną liczbą palet EUR przed podpisaniem dokumentu WZ w systemie WMS.')),

-- id=3: [PRZYPADEK BRZEGOWY POZA ZASIĘGIEM SQL - DOKŁADNOŚĆ MERYTORYCZNA]
-- Dokument przechodzi wszystkie walidacje SQL, ale zawiera gruby błąd merytoryczny w treści ("4500 PLN dziennie" zamiast "4,50 PLN dziennie").
-- Dodatkowo jego fragment w tabeli `fragmenty` (fragmenty.id=4) został celowo uszkodzony jako pusty łańcuch spacji.
(3, 'Regulamin pracy zdalnej i hybrydowej',
 'Pracownik biurowy może wykonywać pracę zdalną przez maksymalnie 8 dni w miesiącu kalendarzowym po akceptacji wniosku w portalu kadrowym. Ekwiwalent za prąd wynosi 4500 PLN dziennie.',
 'v1.2', 'obowiazujacy', '2026-02-01', '2027-12-31', 'hr@nordvist.example', 'HR',
 'intranet.nordvist.example/hr/praca-zdalna', md5('Pracownik biurowy może wykonywać pracę zdalną przez maksymalnie 8 dni w miesiącu kalendarzowym po akceptacji wniosku w portalu kadrowym. Ekwiwalent za prąd wynosi 4500 PLN dziennie.')),

-- id=4 i id=5: [BŁĄD UNIKALNOŚCI - DUPLIKAT DOKŁADNY (K01)]
-- id=4 to oryginał, natomiast id=5 ma identyczną treść i hash_tresci (kopia zapasowa z SharePoint).
(4, 'Procedura obsługi reklamacji transportowych',
 'Zgłoszenie uszkodzenia przesyłki paletowej należy zarejestrować w module RMA w ciągu 7 dni roboczych od daty doręczenia wraz z protokołem szkody.',
 'v1.0', 'obowiazujacy', '2025-09-10', '2027-09-10', 'reklamacje@nordvist.example', 'Obsługa Klienta',
 'intranet.nordvist.example/rma/reklamacje', md5('Zgłoszenie uszkodzenia przesyłki paletowej należy zarejestrować w module RMA w ciągu 7 dni roboczych od daty doręczenia wraz z protokołem szkody.')),

(5, 'Procedura obsługi reklamacji transportowych - kopia zapasowa',
 'Zgłoszenie uszkodzenia przesyłki paletowej należy zarejestrować w module RMA w ciągu 7 dni roboczych od daty doręczenia wraz z protokołem szkody.',
 'v1.0', 'archiwalny', '2025-09-12', '2027-09-10', 'reklamacje@nordvist.example', 'Obsługa Klienta',
 'sharepoint.nordvist.example/backup/reklamacje', md5('Zgłoszenie uszkodzenia przesyłki paletowej należy zarejestrować w module RMA w ciągu 7 dni roboczych od daty doręczenia wraz z protokołem szkody.')),

-- id=6 i id=7: [BŁĄD UNIKALNOŚCI - DUPLIKAT ZBLIŻONY / NEAR-DUPLICATE (K02)]
-- id=7 różni się od id=6 wyłącznie jednym słowem ("zespoły" -> "komisje"); ma inny hash MD5, ale similarity(pg_trgm) = 0.8955.
(6, 'Instrukcja inwentaryzacji rocznej skanerami RFID',
 'Inwentaryzacja roczna w strefie wysokiego składowania prowadzona jest przy użyciu czytników RFID serii Zebra przez dwuosobowe zespoły spisowe.',
 'v3.0', 'obowiazujacy', '2026-03-01', '2027-12-31', 'audyt@nordvist.example', 'Logistyka',
 'intranet.nordvist.example/wms/inwentaryzacja', md5('Inwentaryzacja roczna w strefie wysokiego składowania prowadzona jest przy użyciu czytników RFID serii Zebra przez dwuosobowe zespoły spisowe.')),

(7, 'Instrukcja inwentaryzacji rocznej skanerami RFID (import)',
 'Inwentaryzacja roczna w strefie wysokiego składowania prowadzona jest przy użyciu czytników RFID serii Zebra przez dwuosobowe komisje spisowe.',
 'v3.0', 'projekt', '2026-03-05', '2027-12-31', 'audyt@nordvist.example', 'Logistyka',
 'sharepoint.nordvist.example/import/inwentaryzacja', md5('Inwentaryzacja roczna w strefie wysokiego składowania prowadzona jest przy użyciu czytników RFID serii Zebra przez dwuosobowe komisje spisowe.')),

-- id=8 i id=9: [BŁĄD AKTUALNOŚCI - PRZETERMINOWANE DOKUMENTY OBOWIĄZUJĄCE (K03)]
-- Oba dokumenty mają status = 'obowiazujacy', mimo że ich data_waznosci minęła przed datą odniesienia (2026-11-11).
(8, 'Taryfikator opłat paliwowych i drogowych 2024',
 'Dodatek paliwowy BAF dla frachtu krajowego wynosi 11 procent wartości netto zlecenia transportowego zgodnie z tabelą stawek z roku 2024.',
 'v1.0', 'obowiazujacy', '2024-01-02', '2024-12-31', 'cenniki@nordvist.example', 'Finanse',
 'intranet.nordvist.example/finanse/baf-2024', md5('Dodatek paliwowy BAF dla frachtu krajowego wynosi 11 procent wartości netto zlecenia transportowego zgodnie z tabelą stawek z roku 2024.')),

(9, 'Procedura kwarantanny przesyłek celnych tymczasowa',
 'Wszystkie kontenery morskie spoza Unii Europejskiej podlegają obowiązkowemu postojowi kwarantannowemu na terminalu buforowym przez 48 godzin.',
 'v1.1', 'obowiazujacy', '2024-06-01', '2025-06-30', 'clo@nordvist.example', 'Logistyka',
 'intranet.nordvist.example/clo/kwarantanna', md5('Wszystkie kontenery morskie spoza Unii Europejskiej podlegają obowiązkowemu postojowi kwarantannowemu na terminalu buforowym przez 48 godzin.')),

-- id=10 i id=11: [BŁĄD SPÓJNOŚCI - DWIE WERSJE TEGO SAMEGO DOKUMENTU OZNACZONE JAKO OBOWIĄZUJĄCE + SPRZECZNOŚĆ 14 vs 30 DNI (K05)]
-- Oba rekordy mają ten sam tytuł ('Regulamin zwrotów konsumenckich e-commerce') i status 'obowiazujacy',
-- przy czym v1.0 (id=10) podaje termin 14 dni, a v2.0 (id=11) podaje 30 dni.
(10, 'Regulamin zwrotów konsumenckich e-commerce',
 'Klient indywidualny ma prawo do odstąpienia od umowy zawartej na odległość i odesłania towaru w terminie 14 dni kalendarzowych od daty odebrania przesyłki.',
 'v1.0', 'obowiazujacy', '2024-05-10', '2027-05-10', 'ecommerce@nordvist.example', 'Obsługa Klienta',
 'intranet.nordvist.example/regulaminy/zwroty-v1', md5('Klient indywidualny ma prawo do odstąpienia od umowy zawartej na odległość i odesłania towaru w terminie 14 dni kalendarzowych od daty odebrania przesyłki.')),

(11, 'Regulamin zwrotów konsumenckich e-commerce',
 'Kupującemu w sklepie internetowym przysługuje wydłużony czas na bezpłatny zwrot zakupionych produktów wynoszący 30 dni liczonych od momentu dostarczenia paczki.',
 'v2.0', 'obowiazujacy', '2026-01-10', '2028-01-10', 'ecommerce@nordvist.example', 'Obsługa Klienta',
 'intranet.nordvist.example/regulaminy/zwroty-v2', md5('Kupującemu w sklepie internetowym przysługuje wydłużony czas na bezpłatny zwrot zakupionych produktów wynoszący 30 dni liczonych od momentu dostarczenia paczki.')),

-- id=12 i id=13: [PRZYPADEK BRZEGOWY POZA ZASIĘGIEM SQL - SPRZECZNOŚĆ MERYTORYCZNA MIĘDZY RÓŻNYMI DOKUMENTAMI]
-- Dwa odrębne obowiązujące dokumenty z różnymi tytułami i w 100% poprawnymi metadanymi, które wykluczają się merytorycznie:
-- id=12 gwarantuje darmową dostawę od 150 PLN brutto, natomiast id=13 wymaga zamówienia powyżej 250 PLN brutto.
(12, 'Warunki darmowej dostawy dla klientów detalicznych',
 'Darmowa dostawa kurierem standardowym przysługuje dla każdego zamówienia detalicznego o wartości koszyka przekraczającej 150 PLN brutto.',
 'v1.3', 'obowiazujacy', '2026-04-01', '2027-12-31', 'sprzedaz@nordvist.example', 'Sprzedaż',
 'intranet.nordvist.example/sprzedaz/darmowa-dostawa', md5('Darmowa dostawa kurierem standardowym przysługuje dla każdego zamówienia detalicznego o wartości koszyka przekraczającej 150 PLN brutto.')),

(13, 'Tabela kosztów wysyłki krajowej w kanale B2C',
 'Koszt przesyłki kurierskiej krajowej wynosi 19 PLN brutto, natomiast darmowa dostawa realizowana jest wyłącznie dla zamówień powyżej 250 PLN brutto.',
 'v2.0', 'obowiazujacy', '2026-04-15', '2027-12-31', 'cenniki@nordvist.example', 'Finanse',
 'intranet.nordvist.example/finanse/koszty-wysylki', md5('Koszt przesyłki kurierskiej krajowej wynosi 19 PLN brutto, natomiast darmowa dostawa realizowana jest wyłącznie dla zamówień powyżej 250 PLN brutto.')),

-- id=14 i id=15: [BŁĄD KOMPLETNOŚCI - BRAK WŁAŚCICIELA DOKUMENTU (K07)]
-- id=14 ma wartość NULL w kolumnie wlasciciel; id=15 ma łańcuch złożony z samych spacji '   '.
(14, 'Instrukcja awaryjnego uruchamiania agregatu prądotwórczego',
 'W przypadku zaniku napięcia w sieci głównej agregat dieslowski załącza się automatycznie po 15 sekundach przez układ SZR w rozdzielni głównej.',
 'v1.0', 'archiwalny', '2024-10-01', '2026-10-01', NULL, 'Utrzymanie Ruchu',
 'intranet.nordvist.example/ur/agregat', md5('W przypadku zaniku napięcia w sieci głównej agregat dieslowski załącza się automatycznie po 15 sekundach przez układ SZR w rozdzielni głównej.')),

(15, 'Procedura utylizacji akumulatorów trakcyjnych kwasowo-ołowiowych',
 'Zużyte baterie trakcyjne z wózków widłowych należy składować w wannie wychwytowej i przekazywać wyłącznie podmiotom posiadającym wpis w BDO.',
 'v1.2', 'archiwalny', '2024-12-01', '2026-12-01', '   ', 'BHP i Środowisko',
 'intranet.nordvist.example/bhp/akumulatory', md5('Zużyte baterie trakcyjne z wózków widłowych należy składować w wannie wychwytowej i przekazywać wyłącznie podmiotom posiadającym wpis w BDO.')),

-- id=16: [BŁĄD ZGODNOŚCI FORMATU METADANYCH (K10)]
-- Niepoprawny format adresu e-mail właściciela ('#' zamiast '@') oraz numeru wersji ('wersja_2.0' zamiast wzorca 'vX.Y').
(16, 'Zasady przydziału odzieży roboczej i ochronnej',
 'Pracownikom strefy mroźni przysługuje certyfikowana odzież termoizolacyjna oraz obuwie ochronne klasy S3 wymieniane raz na 12 miesięcy.',
 'wersja_2.0', 'projekt', '2026-01-20', '2027-12-31', 'bhp.admin#nordvist.example', 'BHP i Środowisko',
 'intranet.nordvist.example/bhp/odziez', md5('Pracownikom strefy mroźni przysługuje certyfikowana odzież termoizolacyjna oraz obuwie ochronne klasy S3 wymieniane raz na 12 miesięcy.')),

-- id=17: [BŁĄD DOKŁADNOŚCI TECHNICZNEJ - ROZJAZD HASH_TRESCI / INDEX DRIFT (K11)]
-- Treść dokumentu została zaktualizowana, ale pole hash_tresci ma wyzerowany skrót '00000000000000000000000000000000'.
(17, 'Standard pakowania przesyłek delikatnych i szklanych',
 'Każdy wyrób szklany wymaga zastosowania dwuwarstwowej folii bąbelkowej, narożników tekturowych oraz taśmy ostrzegawczej z napisem OSTROŻNIE SZKŁO.',
 'v1.5', 'obowiazujacy', '2026-02-14', '2027-12-31', 'jakosc@nordvist.example', 'Logistyka',
 'intranet.nordvist.example/pakowanie/szklo', '00000000000000000000000000000000'),

-- id=18 i id=19: [BŁĄD UNIKALNOŚCI - DRUGA PARA DUPLIKATÓW DOKŁADNYCH (K01)]
-- id=19 jest dokładnym duplikatem treści dokumentu id=18 pozostałym po migracji ze starego Confluence.
(18, 'Instrukcja ewakuacji przeciwpożarowej hali magazynowej H4',
 'Po usłyszeniu sygnału dźwiękowego systemu DSO wszyscy pracownicy hali H4 zobowiązani są do udania się do punktu zbiórki przy bramie północnej B1.',
 'v1.1', 'obowiazujacy', '2025-08-01', '2027-08-01', 'bhp@nordvist.example', 'BHP i Środowisko',
 'intranet.nordvist.example/bhp/ewakuacja-h4', md5('Po usłyszeniu sygnału dźwiękowego systemu DSO wszyscy pracownicy hali H4 zobowiązani są do udania się do punktu zbiórki przy bramie północnej B1.')),

(19, 'Ewakuacja PPOŻ hala H4 - duplikat z migracji',
 'Po usłyszeniu sygnału dźwiękowego systemu DSO wszyscy pracownicy hali H4 zobowiązani są do udania się do punktu zbiórki przy bramie północnej B1.',
 'v1.1', 'archiwalny', '2025-08-01', '2027-08-01', 'bhp@nordvist.example', 'BHP i Środowisko',
 'confluence.nordvist.example/old/ewakuacja-h4', md5('Po usłyszeniu sygnału dźwiękowego systemu DSO wszyscy pracownicy hali H4 zobowiązani są do udania się do punktu zbiórki przy bramie północnej B1.')),

-- id=20 i id=21: [BŁĄD UNIKALNOŚCI - DRUGA PARA DUPLIKATÓW ZBLIŻONYCH / NEAR-DUPLICATES (K02)]
-- id=21 różni się od id=20 jednym słowem ("weryfikuje" -> "sprawdza"); similarity(pg_trgm) = 0.8707.
(20, 'Procedura weryfikacji kontrahenta na białej liście podatników VAT',
 'Przed zleceniem przelewu powyżej 15000 PLN brutto dział księgowości weryfikuje rachunek bankowy dostawcy w wykazie podatników VAT Ministerstwa Finansów.',
 'v2.2', 'obowiazujacy', '2026-01-05', '2027-12-31', 'ksiegowosc@nordvist.example', 'Finanse',
 'intranet.nordvist.example/finanse/biala-lista', md5('Przed zleceniem przelewu powyżej 15000 PLN brutto dział księgowości weryfikuje rachunek bankowy dostawcy w wykazie podatników VAT Ministerstwa Finansów.')),

(21, 'Procedura weryfikacji kontrahenta na białej liście VAT - szkic',
 'Przed zleceniem przelewu powyżej 15000 PLN brutto dział księgowości sprawdza rachunek bankowy dostawcy w wykazie podatników VAT Ministerstwa Finansów.',
 'v2.1', 'projekt', '2025-12-20', '2027-12-31', 'ksiegowosc@nordvist.example', 'Finanse',
 'sharepoint.nordvist.example/drafts/biala-lista', md5('Przed zleceniem przelewu powyżej 15000 PLN brutto dział księgowości sprawdza rachunek bankowy dostawcy w wykazie podatników VAT Ministerstwa Finansów.')),

-- id=22: [BŁĄD AKTUALNOŚCI - TRZECI PRZETERMINOWANY DOKUMENT OBOWIĄZUJĄCY (K03)]
-- Status 'obowiazujacy', mimo że data_waznosci upłynęła 2026-01-31.
(22, 'Harmonogram przeglądów regałów paletowych na rok 2025',
 'Okresowy przegląd ekspercki konstrukcji regałów rzędowych w magazynie w Poznaniu musi zostać zakończony protokołem odbioru do dnia 31 stycznia 2026 roku.',
 'v1.0', 'obowiazujacy', '2025-01-10', '2026-01-31', 'ur@nordvist.example', 'Utrzymanie Ruchu',
 'intranet.nordvist.example/ur/regaly-2025', md5('Okresowy przegląd ekspercki konstrukcji regałów rzędowych w magazynie w Poznaniu musi zostać zakończony protokołem odbioru do dnia 31 stycznia 2026 roku.')),

-- id=23: [BŁĄD AKTUALNOŚCI - STARY DOKUMENT OBOWIĄZUJĄCY BEZ DATY WAŻNOŚCI/PRZEGLĄDU (K04)]
-- Opublikowany ponad 5 lat temu (2021-05-10), nadal 'obowiazujacy', ale data_waznosci IS NULL.
(23, 'Procedura archiwizacji papierowych listów przewozowych CMR',
 'Oryginały międzynarodowych listów przewozowych CMR po zeskanowaniu do repozytorium optycznego przechowuje się w archiwum zakładowym przez 5 lat.',
 'v1.0', 'obowiazujacy', '2021-05-10', NULL, 'administracja@nordvist.example', 'Administracja',
 'intranet.nordvist.example/admin/archiwum-cmr', md5('Oryginały międzynarodowych listów przewozowych CMR po zeskanowaniu do repozytorium optycznego przechowuje się w archiwum zakładowym przez 5 lat.')),

-- id=24: [BŁĄD SPÓJNOŚCI - ANOMALIA CHRONOLOGICZNA DAT (K06)]
-- data_waznosci (2025-03-15) jest wcześniejsza niż data_publikacji (2026-03-15).
(24, 'Instrukcja plombowania naczep chłodniczych w transporcie farmaceutycznym',
 'Każda naczepa chłodnicza przewożąca produkty lecznicze w reżimie GDP musi zostać zabezpieczona plombą wysokiego bezpieczeństwa z unikalnym numerem seryjnym.',
 'v1.3', 'projekt', '2026-03-15', '2025-03-15', 'gdp@nordvist.example', 'Jakość',
 'intranet.nordvist.example/gdp/plombowanie', md5('Każda naczepa chłodnicza przewożąca produkty lecznicze w reżimie GDP musi zostać zabezpieczona plombą wysokiego bezpieczeństwa z unikalnym numerem seryjnym.')),

-- id=25: [BŁĄD KOMPLETNOŚCI - BRAK KATEGORII DOKUMENTU (K07)]
-- Kolumna kategoria ma wartość NULL (uniemożliwia filtrowanie po obszarze biznesowym).
(25, 'Zasady korzystania z kart flotowych przez kierowców zawodowych',
 'Karta paliwowa przypisana jest do numeru rejestracyjnego ciągnika siodłowego i może być używana wyłącznie do zakupu oleju napędowego, AdBlue oraz opłat autostradowych.',
 'v1.1', 'archiwalny', '2024-02-10', '2026-02-10', 'flota@nordvist.example', NULL,
 'intranet.nordvist.example/flota/karty-paliwowe', md5('Karta paliwowa przypisana jest do numeru rejestracyjnego ciągnika siodłowego i może być używana wyłącznie do zakupu oleju napędowego, AdBlue oraz opłat autostradowych.')),

-- id=26: [BŁĄD KOMPLETNOŚCI INDEKSU - OBOWIĄZUJĄCY DOKUMENT BEZ FRAGMENTÓW (K08)]
-- Dokument ma status 'obowiazujacy', ale proces chunkingu pominął go i w tabeli `fragmenty` nie ma dla niego żadnego wpisu (FP1 Missing Content).
(26, 'Procedura zgłaszania incydentów naruszenia ochrony danych osobowych RODO',
 'Każde podejrzenie wycieku danych osobowych klientów lub pracowników należy zgłosić Inspektorowi Ochrony Danych w ciągu 4 godzin od wykrycia zdarzenia.',
 'v2.0', 'obowiazujacy', '2026-05-01', '2028-05-01', 'iod@nordvist.example', 'Bezpieczeństwo',
 'intranet.nordvist.example/rodo/incydenty', md5('Każde podejrzenie wycieku danych osobowych klientów lub pracowników należy zgłosić Inspektorowi Ochrony Danych w ciągu 4 godzin od wykrycia zdarzenia.')),

-- id=27: Poprawny dokument archiwalny
(27, 'Instrukcja obsługi terminali mobilnych z systemem Android w strefie kompletacji',
 'Przed rozpoczęciem zmiany magazynier pobiera kolektor danych z szafy ładującej i loguje się indywidualnym identyfikatorem pracownika oraz kodem PIN.',
 'v2.0', 'archiwalny', '2024-04-20', '2026-04-20', 'it@nordvist.example', 'IT',
 'intranet.nordvist.example/it/terminale', md5('Przed rozpoczęciem zmiany magazynier pobiera kolektor danych z szafy ładującej i loguje się indywidualnym identyfikatorem pracownika oraz kodem PIN.')),

-- id=28: [BŁĄD DOKŁADNOŚCI TECHNICZNEJ - DRUGI ROZJAZD HASH_TRESCI (K11)]
-- Zapisany hash_tresci to 'ffffffffffffffffffffffffffffffff' zamiast rzeczywistego skrótu MD5.
(28, 'Regulamin przyznawania premii frekwencyjnej i jakościowej w magazynie',
 'Premia jakościowa w wysokości do 15 procent wynagrodzenia zasadniczego przysługuje pracownikowi, który w danym miesiącu nie przekroczył progu 2 błędów kompletacyjnych.',
 'v1.4', 'projekt', '2026-01-12', '2027-12-31', 'hr@nordvist.example', 'HR',
 'intranet.nordvist.example/hr/regulamin-premii', 'ffffffffffffffffffffffffffffffff'),

-- id=29: [BŁĄD DOKŁADNOŚCI TREŚCI - NIEROZWIĄZANY PLACEHOLDER SZABLONU (K12)]
-- W treści pozostał znacznik zmiennej szablonowej '{{LIMIT_NOCLEGU_PLN}}' zamiast kwoty.
(29, 'Tabela diet i limitów noclegowych w podróżach służbowych krajowych',
 'Maksymalny limit zwrotu kosztów noclegu bez zgody dyrektora pionu wynosi {{LIMIT_NOCLEGU_PLN}} PLN brutto za jedną dobę hotelową na terenie Polski.',
 'v1.0', 'obowiazujacy', '2026-06-01', '2027-12-31', 'finanse@nordvist.example', 'Finanse',
 'intranet.nordvist.example/finanse/delegacje', md5('Maksymalny limit zwrotu kosztów noclegu bez zgody dyrektora pionu wynosi {{LIMIT_NOCLEGU_PLN}} PLN brutto za jedną dobę hotelową na terenie Polski.')),

-- id=30: [BŁĄD DOKŁADNOŚCI TREŚCI - ARTEFAKT USZKODZONEGO SKANOWANIA OCR (K12)]
-- W treści znajduje się znacznik błędu rozpoznawania tekstu '[BŁĄD_OCR]'.
(30, 'Instrukcja kontroli temperatury w komorach chłodniczych skan archiwalny',
 'Pomiar temperatury w komorze chłodniczej nr 2 [BŁĄD_OCR] musi mieścić się w przedziale od +2°C do +8°C przez cały okres składowania ładunku.',
 'v1.0', 'archiwalny', '2023-03-10', '2025-03-10', 'jakosc@nordvist.example', 'Jakość',
 'intranet.nordvist.example/archiwum/skan-chlodnia', md5('Pomiar temperatury w komorze chłodniczej nr 2 [BŁĄD_OCR] musi mieścić się w przedziale od +2°C do +8°C przez cały okres składowania ładunku.'));

-- ============================================================================
-- WSTAWIENIE 18 REKORDÓW DO TABELI `fragmenty` (DLA DOKUMENTÓW OBOWIĄZUJĄCYCH)
-- Uwaga: Dokument id=26 ('obowiazujacy') został celowo pominięty (błąd K08).
-- Zaszyte błędy w tabeli `fragmenty` (Zgodność formatu - K09):
--   - fragmenty.id=4  (pusty fragment złożony ze spacji '   ' dla dokumentu id=3)
--   - fragmenty.id=9  (zbyt krótki fragment: 33 znaki < 40, sam nagłówek dla dokumentu id=10)
--   - fragmenty.id=15 (zbyt krótki fragment: 13 znaków < 40, sama stopka 'Strona 4 z 12' dla id=20)
-- ============================================================================

INSERT INTO fragmenty (id, dokument_id, nr, tresc) VALUES
(1,  1,  1, 'Każdy pracownik NordVist Logistyka Sp. z o.o. zobowiązany jest do szyfrowania dysków służbowych kluczem BitLocker.'),
(2,  1,  2, 'Zmiana hasła domenowego w systemie Active Directory jest wymuszana automatycznie co 90 dni kalendarzowych.'),
(3,  2,  1, 'Operator wózka widłowego weryfikuje zgodność listy przewozowej z fizyczną liczbą palet EUR przed podpisaniem dokumentu WZ w systemie WMS.'),
-- [BŁĄD ZGODNOŚCI FORMATU (K09) - fragmenty.id=4]: pusty fragment po podziale strony
(4,  3,  1, '   '),
(5,  4,  1, 'Zgłoszenie uszkodzenia przesyłki paletowej należy zarejestrować w module RMA w ciągu 7 dni roboczych od daty doręczenia wraz z protokołem szkody.'),
(6,  6,  1, 'Inwentaryzacja roczna w strefie wysokiego składowania prowadzona jest przy użyciu czytników RFID serii Zebra przez dwuosobowe zespoły spisowe.'),
(7,  8,  1, 'Dodatek paliwowy BAF dla frachtu krajowego wynosi 11 procent wartości netto zlecenia transportowego zgodnie z tabelą stawek z roku 2024.'),
(8,  9,  1, 'Wszystkie kontenery morskie spoza Unii Europejskiej podlegają obowiązkowemu postojowi kwarantannowemu na terminalu buforowym przez 48 godzin.'),
-- [BŁĄD ZGODNOŚCI FORMATU (K09) - fragmenty.id=9]: zbyt krótki fragment (33 znaki < 40), sam nagłówek rozdziału bez treści
(9,  10, 1, 'Rozdział 3. Postanowienia ogólne.'),
(10, 11, 1, 'Kupującemu w sklepie internetowym przysługuje wydłużony czas na bezpłatny zwrot zakupionych produktów wynoszący 30 dni liczonych od momentu dostarczenia paczki.'),
(11, 12, 1, 'Darmowa dostawa kurierem standardowym przysługuje dla każdego zamówienia detalicznego o wartości koszyka przekraczającej 150 PLN brutto.'),
(12, 13, 1, 'Koszt przesyłki kurierskiej krajowej wynosi 19 PLN brutto, natomiast darmowa dostawa realizowana jest wyłącznie dla zamówień powyżej 250 PLN brutto.'),
(13, 17, 1, 'Każdy wyrób szklany wymaga zastosowania dwuwarstwowej folii bąbelkowej, narożników tekturowych oraz taśmy ostrzegawczej z napisem OSTROŻNIE SZKŁO.'),
(14, 18, 1, 'Po usłyszeniu sygnału dźwiękowego systemu DSO wszyscy pracownicy hali H4 zobowiązani są do udania się do punktu zbiórki przy bramie północnej B1.'),
-- [BŁĄD ZGODNOŚCI FORMATU (K09) - fragmenty.id=15]: zbyt krótki fragment (13 znaków < 40), wycięta stopka strony PDF
(15, 20, 1, 'Strona 4 z 12'),
(16, 22, 1, 'Okresowy przegląd ekspercki konstrukcji regałów rzędowych w magazynie w Poznaniu musi zostać zakończony protokołem odbioru do dnia 31 stycznia 2026 roku.'),
(17, 23, 1, 'Oryginały międzynarodowych listów przewozowych CMR po zeskanowaniu do repozytorium optycznego przechowuje się w archiwum zakładowym przez 5 lat.'),
(18, 29, 1, 'Maksymalny limit zwrotu kosztów noclegu bez zgody dyrektora pionu wynosi {{LIMIT_NOCLEGU_PLN}} PLN brutto za jedną dobę hotelową na terenie Polski.');

-- ============================================================================
-- 12 REGUŁ JAKOŚCI DANYCH (każda zwraca rekordy do naprawy)
-- ============================================================================

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

-- ============================================================================
-- ZBIORCZY SCORECARD JAKOŚCI BAZY WIEDZY RAG (PostgreSQL 16)
-- Wzór wyniku ogólnego: TRUNC((SUM(poprawne)::numeric / SUM(sprawdzone)::numeric) * 100, 2)
-- ============================================================================

WITH baza_stat AS (
    SELECT
        (SELECT COUNT(*)::integer FROM dokumenty) AS n_dok,
        (SELECT COUNT(*)::integer FROM fragmenty) AS n_frag
),
oceny_regul AS (
    -- K01: Unikalność - Duplikaty dokładne (hash_tresci)
    SELECT
        1 AS kol,
        'K01' AS kod_reguly,
        'Unikalność' AS wymiar,
        'Brak duplikatów dokładnych (hash_tresci)' AS nazwa_reguly,
        (SELECT n_dok FROM baza_stat) AS sprawdzone,
        COUNT(DISTINCT d1.id)::integer AS bledne,
        COALESCE(NULLIF(array_to_string(ARRAY(SELECT DISTINCT u FROM unnest(array_agg(d1.id)) u ORDER BY u), ', '), ''), '-') AS bledne_id,
        98.00::numeric(5,2) AS sla_proc
    FROM dokumenty d1
    JOIN dokumenty d2 ON d1.hash_tresci = d2.hash_tresci AND d2.id < d1.id

    UNION ALL

    -- K02: Unikalność - Duplikaty zbliżone (pg_trgm >= 0.70)
    SELECT
        2, 'K02', 'Unikalność', 'Brak duplikatów zbliżonych (pg_trgm >= 0.70)',
        (SELECT n_dok FROM baza_stat),
        COUNT(DISTINCT d1.id)::integer,
        COALESCE(NULLIF(array_to_string(ARRAY(SELECT DISTINCT u FROM unnest(array_agg(d1.id)) u ORDER BY u), ', '), ''), '-'),
        95.00::numeric(5,2)
    FROM dokumenty d1
    JOIN dokumenty d2 ON d2.id < d1.id AND d1.tresc <> d2.tresc AND similarity(d1.tresc, d2.tresc) >= 0.70

    UNION ALL

    -- K03: Aktualność - Przeterminowane dokumenty obowiązujące
    SELECT
        3, 'K03', 'Aktualność', 'Brak przeterminowanych dokumentów obowiązujących',
        (SELECT n_dok FROM baza_stat),
        COUNT(*)::integer,
        COALESCE(string_agg(id::text, ', ' ORDER BY id), '-'),
        98.00::numeric(5,2)
    FROM dokumenty
    WHERE status = 'obowiazujacy' AND data_waznosci IS NOT NULL AND data_waznosci < '2026-11-11'::date

    UNION ALL

    -- K04: Aktualność - Stare dokumenty (>3 lata) bez daty ważności
    SELECT
        4, 'K04', 'Aktualność', 'Data ważności dla dokumentów starszych niż 3 lata',
        (SELECT n_dok FROM baza_stat),
        COUNT(*)::integer,
        COALESCE(string_agg(id::text, ', ' ORDER BY id), '-'),
        95.00::numeric(5,2)
    FROM dokumenty
    WHERE status = 'obowiazujacy' AND data_publikacji < '2023-11-11'::date AND data_waznosci IS NULL

    UNION ALL

    -- K05: Spójność - Kolizja wersji obowiązujących o tym samym tytule
    SELECT
        5, 'K05', 'Spójność', 'Tylko jedna obowiązująca wersja dokumentu o danym tytule',
        (SELECT n_dok FROM baza_stat),
        COUNT(*)::integer,
        COALESCE(string_agg(d.id::text, ', ' ORDER BY d.id), '-'),
        100.00::numeric(5,2)
    FROM dokumenty d
    WHERE d.status = 'obowiazujacy'
      AND EXISTS (
          SELECT 1 FROM dokumenty d2
          WHERE d2.tytul = d.tytul AND d2.status = 'obowiazujacy' AND d2.id <> d.id
      )

    UNION ALL

    -- K06: Spójność - Chronologia dat (data_waznosci >= data_publikacji)
    SELECT
        6, 'K06', 'Spójność', 'Spójność chronologiczna dat (data_waznosci >= data_publikacji)',
        (SELECT n_dok FROM baza_stat),
        COUNT(*)::integer,
        COALESCE(string_agg(id::text, ', ' ORDER BY id), '-'),
        100.00::numeric(5,2)
    FROM dokumenty
    WHERE data_waznosci IS NOT NULL AND data_waznosci < data_publikacji

    UNION ALL

    -- K07: Kompletność - Właściciel oraz kategoria
    SELECT
        7, 'K07', 'Kompletność', 'Wypełniony właściciel oraz kategoria dokumentu',
        (SELECT n_dok FROM baza_stat),
        COUNT(*)::integer,
        COALESCE(string_agg(id::text, ', ' ORDER BY id), '-'),
        95.00::numeric(5,2)
    FROM dokumenty
    WHERE wlasciciel IS NULL OR btrim(wlasciciel) = '' OR kategoria IS NULL OR btrim(kategoria) = ''

    UNION ALL

    -- K08: Kompletność - Pokrycie dokumentów obowiązujących fragmentami
    SELECT
        8, 'K08', 'Kompletność', 'Obowiązujący dokument posiada fragmenty w tabeli fragmenty',
        (SELECT n_dok FROM baza_stat),
        COUNT(*)::integer,
        COALESCE(string_agg(d.id::text, ', ' ORDER BY d.id), '-'),
        100.00::numeric(5,2)
    FROM dokumenty d
    LEFT JOIN fragmenty f ON f.dokument_id = d.id
    WHERE d.status = 'obowiazujacy' AND f.id IS NULL

    UNION ALL

    -- K09: Zgodność formatu - Minimalna długość fragmentu (>= 40 znaków po btrim)
    SELECT
        9, 'K09', 'Zgodność formatu', 'Minimalna długość fragmentu (>= 40 znaków po btrim)',
        (SELECT n_frag FROM baza_stat),
        COUNT(*)::integer,
        COALESCE(string_agg(id::text, ', ' ORDER BY id), '-'),
        95.00::numeric(5,2)
    FROM fragmenty
    WHERE char_length(btrim(tresc)) < 40

    UNION ALL

    -- K10: Zgodność formatu - Format e-mail (.example) i wersji (vX.Y)
    SELECT
        10, 'K10', 'Zgodność formatu', 'Poprawny format e-mail właściciela (.example) i wersji (vX.Y)',
        (SELECT n_dok FROM baza_stat),
        COUNT(*)::integer,
        COALESCE(string_agg(id::text, ', ' ORDER BY id), '-'),
        95.00::numeric(5,2)
    FROM dokumenty
    WHERE (wlasciciel IS NOT NULL AND btrim(wlasciciel) <> '' AND wlasciciel !~ '^[a-z0-9._%+-]+@[a-z0-9.-]+\.example$')
       OR wersja !~ '^v[0-9]+\.[0-9]+$'

    UNION ALL

    -- K11: Dokładność - Integralność skrótu MD5 (hash_tresci = md5(tresc))
    SELECT
        11, 'K11', 'Dokładność', 'Integralność skrótu treści (hash_tresci = md5(tresc))',
        (SELECT n_dok FROM baza_stat),
        COUNT(*)::integer,
        COALESCE(string_agg(id::text, ', ' ORDER BY id), '-'),
        100.00::numeric(5,2)
    FROM dokumenty
    WHERE hash_tresci <> md5(tresc)

    UNION ALL

    -- K12: Dokładność - Brak artefaktów OCR i placeholderów szablonowych
    SELECT
        12, 'K12', 'Dokładność', 'Brak artefaktów OCR i placeholderów {{...}} w treści',
        (SELECT n_dok FROM baza_stat),
        COUNT(*)::integer,
        COALESCE(string_agg(id::text, ', ' ORDER BY id), '-'),
        98.00::numeric(5,2)
    FROM dokumenty
    WHERE tresc ~ '(\{\{.*\}\}|\[BŁĄD_OCR\]|\uFFFD)'
),
wyliczenia AS (
    SELECT
        kol,
        kod_reguly,
        wymiar,
        nazwa_reguly,
        (sprawdzone - bledne) AS poprawne,
        sprawdzone,
        bledne,
        bledne_id,
        TRUNC(((sprawdzone - bledne)::numeric / sprawdzone::numeric) * 100, 2) AS wynik_proc,
        sla_proc
    FROM oceny_regul
)
SELECT
    kod_reguly,
    wymiar,
    nazwa_reguly,
    poprawne,
    sprawdzone,
    bledne,
    bledne_id,
    wynik_proc,
    CASE
        WHEN wynik_proc >= 95.00 THEN 'ZIELONY'
        WHEN wynik_proc >= 85.00 THEN 'ZOLTY'
        ELSE 'CZERWONY'
    END AS semafor,
    sla_proc AS docelowe_sla_przyklad,
    CASE
        WHEN wynik_proc >= sla_proc THEN 'SPEŁNIONE'
        ELSE 'NARUSZONE'
    END AS status_sla
FROM wyliczenia

UNION ALL

-- Wiersz podsumowujący liczony ściśle wg wzoru: SUM(poprawne) / SUM(sprawdzone)
SELECT
    'SUMA' AS kod_reguly,
    'WSZYSTKIE (6)' AS wymiar,
    'WYNIK OGÓLNY: SUM(poprawne) / SUM(sprawdzone)' AS nazwa_reguly,
    SUM(poprawne)::integer AS poprawne,
    SUM(sprawdzone)::integer AS sprawdzone,
    SUM(bledne)::integer AS bledne,
    '-' AS bledne_id,
    TRUNC((SUM(poprawne)::numeric / SUM(sprawdzone)::numeric) * 100, 2) AS wynik_proc,
    CASE
        WHEN TRUNC((SUM(poprawne)::numeric / SUM(sprawdzone)::numeric) * 100, 2) >= 95.00 THEN 'ZIELONY'
        WHEN TRUNC((SUM(poprawne)::numeric / SUM(sprawdzone)::numeric) * 100, 2) >= 85.00 THEN 'ZOLTY'
        ELSE 'CZERWONY'
    END AS semafor,
    97.00::numeric(5,2) AS docelowe_sla_przyklad,
    CASE
        WHEN TRUNC((SUM(poprawne)::numeric / SUM(sprawdzone)::numeric) * 100, 2) >= 97.00 THEN 'SPEŁNIONE'
        ELSE 'NARUSZONE'
    END AS status_sla
FROM wyliczenia
ORDER BY kod_reguly;

-- ============================================================================
-- DEMO: GRANICE PODOBIEŃSTWA TRIGRAMOWEGO (pg_trgm)
-- Trigramy mierzą podobieństwo znaków, a nie znaczenia zdań.
-- ============================================================================
SELECT 'zmiana liczby 14 -> 30 dni (sprzeczne wartości)' AS przypadek,
       ROUND(similarity(
           'Klient ma prawo do zwrotu towaru w terminie 14 dni kalendarzowych od daty odebrania przesyłki.',
           'Klient ma prawo do zwrotu towaru w terminie 30 dni kalendarzowych od daty odebrania przesyłki.')::numeric, 4) AS podobienstwo
UNION ALL
SELECT 'przysługuje / nie przysługuje (przeciwne znaczenie)',
       ROUND(similarity(
           'Zwrot kosztów przesyłki przysługuje klientowi w każdym przypadku odstąpienia od umowy.',
           'Zwrot kosztów przesyłki nie przysługuje klientowi w żadnym przypadku odstąpienia od umowy.')::numeric, 4)
UNION ALL
SELECT 'parafraza (to samo znaczenie, inne słowa)',
       ROUND(similarity(
           'Klient może zwrócić towar w ciągu 14 dni od odebrania paczki.',
           'Przysługuje Ci czternaście dni na odesłanie zakupu po dostarczeniu przesyłki.')::numeric, 4)
UNION ALL
SELECT 'dokumenty id=12 i id=13 (darmowa dostawa od 150 vs od 250 PLN)',
       ROUND(similarity((SELECT tresc FROM dokumenty WHERE id = 12),
                        (SELECT tresc FROM dokumenty WHERE id = 13))::numeric, 4);
