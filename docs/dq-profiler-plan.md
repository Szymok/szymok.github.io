# Plan: DQ Profiler, profilowanie pliku CSV w przeglądarce

Projekt obok strony. Osobne repozytorium (`dq-profiler`), artefakt wdrażany na stronę jako statyczny bundle. Dokument jest planem, nie specyfikacją końcową.

## Cel i odbiorca

Osoba z małej lub średniej firmy (Excel, czasem SQL) przeciąga plik CSV i w minutę widzi raport jakości w sześciu wymiarach z semaforem 95% / 85%. Raport kończy się wnioskiem: „tyle widać z jednego pliku, audyt sprawdza resztę".

Narzędzie ma być **dowodem kompetencji**, nie zamiennikiem audytu. Mierzy to, co da się zmierzyć z jednego pliku, i mówi wprost, czego nie mierzy.

## Zasady nienegocjowalne

1. **Dane nie opuszczają przeglądarki.** Zero żądań sieciowych z zawartością pliku. Weryfikowalne w zakładce Network i testem automatycznym.
2. **Zero zależności od zewnętrznych CDN.** Bundle samodzielnie hostowany z sumą SRI, jak pozostałe biblioteki na stronie.
3. **Bez zapisu danych.** Brak localStorage z zawartością pliku. Zapamiętujemy co najwyżej ustawienia reguł, i to wyłącznie za zgodą użytkownika.
4. **Jawne ograniczenia** na stronie narzędzia: rozmiar pliku, co jest mierzone, czego nie.

## Zakres

### MVP (wersja 0.1)
- Wczytanie CSV (separator wykrywany, UTF-8 i Windows-1250, nagłówek).
- Profil kolumn: typ wnioskowany, % pustych (NULL, pusty tekst, spacje, wartości zastępcze `n/d`, `-`, `brak`), liczba wartości unikalnych, min/max dla liczb i dat.
- Wymiary: **kompletność**, **unikalność** (duplikaty wierszy i klucza), **ważność** (format: e-mail, NIP z sumą kontrolną, kod pocztowy, data, zakres).
- Wynik na wymiar i łączny, semafor, lista 10 najgorszych kolumn.
- Eksport raportu: HTML do pobrania i JSON.

### Wersja 0.2
- Własne reguły w YAML (ten sam schemat co `football-dq`, patrz niżej).
- Kompletność warunkowa („NIP wymagany, gdy typ = firma").
- Spójność między polami i aktualność (daty z przyszłości, przeterminowane).

### Poza zakresem
Łączenie z bazami, wysyłanie na serwer, konta użytkowników, profilowanie wielu plików naraz, Excel `.xlsx` (dopiero po wersji 0.2), automatyczne naprawianie danych.

## Relacja z football-dq

Sprawdziłem repozytorium `C:\Dev\Repos\football-dq`:

- **Format reguł nadaje się do ponownego użycia.** `rules/xg_quality_rules.yaml` ma pola: `name`, `dimension`, `description`, `column(s)`, `check`, `params`, `severity`. Typy sprawdzeń w pliku: `not_null`, `between`, `unique_combination`.
- **Silnik Pythona nie nadaje się.** `src/quality/checks.py` (356 linii) jest związany z SQLAlchemy i modelami piłkarskimi. W przeglądarce trzeba napisać go od nowa.
- **Projekt jest w trakcie przejścia na Rust** (workspace `crates/`: api, cli, core, domain, extractors; serwer Axum). W katalogu głównym leżą pliki robocze (`error.log`, `errors.txt`, `link_error.txt`, `test_err.txt`, `under_err.txt`) i niezacommitowane zmiany (`Cargo.lock`, `crates/cli/src/main.rs`), a lokalna gałąź jest o jeden commit przed zdalną.
- **Decyzja:** profiler przejmuje **schemat YAML reguł** jako wspólny kontrakt, ale nie zależy od kodu `football-dq`. Dzięki temu ten sam plik reguł może działać w obu narzędziach, a spójność można pokazać w jednym wpisie (wpis #12 „Data Quality as code").

## Architektura (alternatywy)

| Opcja | Opis | Za | Przeciw |
|---|---|---|---|
| **A. Czysty JS/TypeScript** (rekomendowana na MVP) | Własny parser CSV w strumieniu i silnik reguł w TS | mały bundle (dziesiątki KB), pełna kontrola, prosta analiza prywatności | własny parser CSV, ograniczenie rozmiaru pliku (praktycznie do kilkudziesięciu MB) |
| **B. DuckDB-WASM** | Reguły tłumaczone na SQL, wykonywane w przeglądarce | duże pliki, SQL gratis, reguły = zapytania z wpisu #1 | wasm ok. kilku MB do samodzielnego hostowania, wolniejszy start |
| **C. Rust → WASM** | Silnik reguł w Rust, reuse z `crates/core` | jedna implementacja dla CLI, API i przeglądarki | cięższy łańcuch narzędzi, ryzyko rozjechania z planem Rust w `football-dq` |
| **D. Pyodide** | Python w przeglądarce, reuse kodu | zero przepisywania | kilkanaście MB, wolny start, kod i tak związany z SQLAlchemy |

**Rekomendacja:** A dla MVP i 0.2. Opcja B jako 0.3, jeśli użytkownicy będą potrzebowali plików większych niż limit (decyzja po danych z Umami, nie z założeń). Opcja C tylko wtedy, gdy silnik reguł w Rust powstanie i tak.

**Stos:** TypeScript, Vite (build do pojedynczego `dq-profiler.js` + CSS), Vitest, Playwright do testu sieci. Wykresy: lekki SVG własny, bez Chart.js (zgodnie z dotychczasowym odchudzaniem strony).

## Integracja ze stroną

- Strona narzędzia: `/narzedzia/profil-danych/` (layout `page`), w menu pod „więcej".
- Bundle kopiowany do `assets/js/dq-profiler/` jako plik wydania (nie submoduł), z sumą SRI w `_config.yml` obok pozostałych bibliotek.
- Aktualizacja `privacy-policy.md`: pliki przetwarzane lokalnie, brak wysyłania.
- Linki: wpis #1 (kompletność w SQL) → narzędzie, narzędzie → scorecard, test dojrzałości, oferta.
- Nowa pozycja w Umami: zdarzenia `profiler_started`, `profiler_report_exported` (bez nazw kolumn i wartości).

## Etapy i szacunek

| Etap | Zakres | Czas |
|---|---|---|
| 0. Szkielet | repo, Vite/TS, CI, lint, licencja | 0,5 dnia |
| 1. Parser | CSV w strumieniu, separator, kodowanie, testy na plikach brzegowych | 1 dzień |
| 2. Profil kolumn | typy, braki, unikalność | 1 dzień |
| 3. Reguły ważności | e-mail, NIP (suma kontrolna), kod pocztowy, data, zakresy | 1 dzień |
| 4. Raport | semafor, wymiary, eksport HTML i JSON | 1 dzień |
| 5. Integracja ze stroną | strona, polityka prywatności, SRI, linki, zdarzenia | 0,5 dnia |
| 6. Test sieci i dostępność | Playwright (brak żądań z danymi), klawiatura, kontrast, telefon | 0,5 dnia |
| **Razem MVP** | | **ok. 5–6 dni roboczych** |

Wersja 0.2 (YAML, warunkowa kompletność): kolejne 2–3 dni.

## Kryteria sukcesu (mierzalne)

1. Plik 10 MB / 100 tys. wierszy: profil w **< 5 s** na laptopie biznesowym.
2. **Zero żądań sieciowych** po wczytaniu pliku, potwierdzone testem Playwright.
3. Wyniki zgodne z zapytaniami SQL z wpisu #1 na tych samych danych syntetycznych (76,8% kompletności, 41,7% rekordów kompletnych).
4. Pokrycie testami silnika reguł **> 80%**, bez błędów lintera i typów.
5. Lighthouse strony narzędzia: dostępność ≥ 95, brak regresji wydajności strony głównej.
6. Pierwsze 30 dni po publikacji: odnotowane użycia w Umami i przynajmniej jedno zapytanie o audyt z kontekstem narzędzia (cel orientacyjny, nie gwarancja przy obecnym ruchu).

## Pre-mortem: co może pójść źle

| Ryzyko | Skutek | Środek zaradczy |
|---|---|---|
| Użytkownik wrzuca dane osobowe i czuje obawę | brak zaufania | komunikat nad polem pliku, dowód w zakładce Network, kod otwarty |
| Kodowanie Windows-1250 i różne separatory psują profil | błędne wyniki, utrata wiarygodności | zestaw plików brzegowych w testach, ręczny wybór separatora i kodowania |
| Narzędzie zastępuje audyt w oczach klienta | mniej zapytań | wniosek końcowy w raporcie i jawna lista tego, czego nie mierzy |
| Duży plik zawiesza kartę | zła pierwsza ocena | strumieniowanie, Web Worker, limit i komunikat |
| Samodzielne utrzymanie rozjeżdża się z ofertą | dług | wersjonowanie bundle, jeden właściciel, changelog |
| Ruch na stronie jest minimalny | narzędzie nikogo nie znajdzie | dystrybucja: wpis #1 jako lejek, post na LinkedIn przy premierze |
| Zawartość NIP/PESEL w przykładach | ryzyko prawne | tylko dane syntetyczne, bez rzeczywistych numerów |

## Pytania otwarte

1. Nazwa i licencja repozytorium (MIT?) oraz czy ma być publiczne od początku.
2. Czy raport HTML ma zawierać stopkę z linkiem do oferty (rekomendacja: tak, jedna linia).
3. Limit rozmiaru pliku w MVP (propozycja: 50 MB, komunikat powyżej).
4. Czy `football-dq` ma pozostać projektem własnym i oddzielnie opisanym, czy ma trafić na stronę jako przykład „DQ as code" (wpis #12)?
