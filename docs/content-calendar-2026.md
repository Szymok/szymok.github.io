# Kalendarz wpisów: 13 października 2026 – 12 stycznia 2027

Jeden wpis tygodniowo, wtorek. Trzy filary w rotacji: **DQ/DG (rdzeń)**, **AI → co z tego dla DQ/DG**, **homelab → co z tego dla DQ/DG**. Każdy wpis prowadzi do oferty (`/audyt-data-quality/`), testu (`/dojrzalosc-dq/`) albo scorecardu (`/scorecard/`).

## Zasady każdego wpisu

1. **Sekcja obowiązkowa w wpisach AI i homelab:** H2 „Co z tego wynika dla Data Quality / Data Governance" z 3 konkretnymi punktami. Bez niej wpis nie wychodzi. To wiąże temat poboczny z ofertą.
2. **Fraza w tytule, w pierwszych 100 słowach i w `description`** (ok. 150 znaków). Jeden wpis = jedno pytanie, na które ktoś wpisuje w Google.
3. **Artefakt do pobrania lub skopiowania** (zapytanie SQL, tabela RACI, workflow, arkusz). To dowód kompetencji, którego nie ma konkurencja bez praktyki, i powód do linkowania.
4. **Minimum 2 linki wewnętrzne:** do innego wpisu i do oferty, testu albo scorecardu. W treści, nie tylko na końcu.
5. **Dane syntetyczne albo własne.** Żadnych danych, zrzutów ekranu ani nazw klientów z pracodawcy (patrz zastrzeżenie o umowie o pracę na końcu).
6. **Dystrybucja w dniu publikacji:** post na LinkedIn z linkiem. Ponowna wzmianka po 7 dniach. Bez linków zewnętrznych domena nie rośnie w wyszukiwarce.
7. **Po 4 tygodniach od publikacji:** sprawdź w Google Search Console zapytania, na które wpis się wyświetla, i dopasuj tytuł oraz nagłówki.

Front matter (zgodny z istniejącymi wpisami): `layout: post`, `title`, `date`, `description`, `tags: [...]`, `categories: [data-governance | homelab]`, `giscus_comments: true`, `toc: {sidebar: left}`.

## Przegląd

| #   | Data  | Filar        | Tytuł roboczy                                                      | Fraza główna                                       | Status              |
| --- | ----- | ------------ | ------------------------------------------------------------------ | -------------------------------------------------- | ------------------- |
| 1   | 13.10 | DQ           | Kompletność danych w SQL: 5 zapytań do uruchomienia dziś           | jak zmierzyć jakość danych, kompletność danych SQL | opublikowany        |
| 4   | 3.11  | DQ           | Reguły jakości danych: 12 przykładów z progami                     | reguły jakości danych przykłady, walidacja NIP     | opublikowany        |
| 2   | 10.11 | AI → DQ      | Dlaczego RAG odpowiada źle: jakość danych w bazie wiedzy           | jakość danych RAG                                  | zaległy, było 20.10 |
| 3   | 17.11 | homelab → DG | Rejestr usług w homelabie jako mały katalog danych                 | katalog danych co to                               | zaległy, było 27.10 |
| 5   | 24.11 | AI → DG      | Zanim wpuścisz Copilota na dane firmy: 7 pytań z Data Governance   | data governance AI, AI governance                  | przesunięty z 10.11 |
| 6   | 1.12  | homelab → DQ | Reguły jakości w n8n: prosty pipeline walidacji danych             | walidacja danych n8n                               | przesunięty z 17.11 |
| 7   | 8.12  | DG           | Data owner i data steward: kto za co odpowiada (RACI)              | data steward co robi, data owner                   | przesunięty z 24.11 |
| 8   | 15.12 | AI → DQ      | LLM w profilowaniu danych: co działa, czego nie robić              | LLM jakość danych                                  | przesunięty z 1.12  |
| 9   | 22.12 | homelab → DG | Retencja danych w praktyce: 24 miesiące w Umami i polityki w Kopii | retencja danych polityka                           | przesunięty z 8.12  |
| 10  | 29.12 | DQ           | Ile kosztują złe dane: prosty model dla firmy średniej wielkości   | koszt złej jakości danych                          | przesunięty z 15.12 |
| 11  | 5.01  | AI → DG      | Prompty jako dane: wersjonowanie, właściciel, jakość               | zarządzanie promptami                              | przesunięty z 22.12 |
| 12  | 12.01 | homelab → DQ | Data Quality as code: reguły w Git z przeglądem zmian              | data quality as code                               | przesunięty z 29.12 |

Wpisy 2 i 3 nie wyszły w terminie (20.10 i 27.10), więc zostały dopisane na kolejne tygodnie, a pozostałe wpisy przesunęły się o dwa tygodnie. Po tej zmianie rdzeń DQ/DG (wpisy 4, 7 i 10) ustępuje tematom pobocznym, więc po 12.01 warto zacząć od wpisu z rdzenia.

Frazy to **hipotezy**, nie dane o wolumenie wyszukiwań. Zweryfikuj je w podpowiedziach Google i w GSC (po 4 tygodniach), zanim ostatecznie ustalisz tytuły.

## Opisy wpisów

### 1. Kompletność danych w SQL: 5 zapytań do uruchomienia dziś (13.10, DQ)

- **Intencja:** ktoś ma bazę i chce policzyć, ile w niej brakuje.
- **Szkielet:** definicja kompletności (link do wpisu o wymiarach) → % NULL w kolumnie → puste łańcuchy i wartości zastępcze („n/d", „-", „brak") → kompletność warunkowa (np. NIP wymagany, gdy klient jest firmą) → trend w czasie → przeniesienie wyniku do scorecardu.
- **Artefakt:** skrypt SQL na danych syntetycznych.
- **CTA:** `/scorecard/` (arkusz) i `/dojrzalosc-dq/`.

### 2. Dlaczego RAG odpowiada źle: jakość danych w bazie wiedzy (10.11, AI → DQ; zaległy, było 20.10)

- **Mostek do DQ:** te same wymiary dotyczą korpusu dokumentów: duplikaty = unikalność, stare wersje = aktualność, sprzeczne dokumenty = spójność, brakujące metadane = kompletność.
- **Przykład własny:** analiza duplikatów w ogrodzie wiedzy (zidentyfikowane 118 kopii notatek). To prawdziwy przypadek, który możesz opisać z liczbami.
- **Artefakt:** checklista „6 wymiarów dla bazy wiedzy AI".
- **Co z tego dla DQ/DG:** jakość danych decyduje o jakości odpowiedzi AI, więc audyt DQ jest warunkiem wstępnym projektu AI.

### 3. Rejestr usług w homelabie jako mały katalog danych (17.11, homelab → DG; zaległy, było 27.10)

- **Mostek do DG:** właściciel, opis, krytyczność i klasyfikacja usługi to dokładnie pola katalogu danych. Inwentarz powstaje przed politykami.
- **Opieraj się na:** wpisach o Kopii i DNS/Pi-hole (link wewnętrzny), z listą 14 źródeł Strażnika jako przykładem rejestru.
- **Artefakt:** szablon rejestru (tabela albo YAML).
- **Co z tego dla DQ/DG:** nie da się mierzyć jakości czegoś, czego nie ma w inwentarzu.

### 4. Reguły jakości danych: 12 przykładów z progami (3.11, DQ; opublikowany)

- **Intencja:** ktoś szuka gotowych reguł do skopiowania.
- **Szkielet:** reguły po wymiarach: NIP (suma kontrolna), e-mail, kod pocztowy, daty z przyszłości, zakresy liczb, słowniki wartości, unikalność klucza, spójność między polami. Dla każdej: zapis, próg akceptacji, sposób naprawy.
- **Artefakt:** arkusz reguł z progami semafora jak w ofercie (95% / 85%).
- **CTA:** audyt, bo „lista reguł z progami" jest jego rezultatem.

### 5. Zanim wpuścisz Copilota na dane firmy: 7 pytań z Data Governance (24.11, AI → DG; było 10.11)

- **Mostek do DG:** klasyfikacja danych, właściciele, uprawnienia i retencja to warunki wstępne AI. Pytania: kto jest właścicielem danych, jakie są wrażliwe, co zostaje w kontekście modelu, kto zatwierdza źródła.
- **Linki wewnętrzne:** wpis o modelach AI i DG, test dojrzałości.
- **Co z tego dla DQ/DG:** AI nie omija problemów z danymi, tylko je przyspiesza.

### 6. Reguły jakości w n8n: prosty pipeline walidacji danych (1.12, homelab → DQ; było 17.11)

- **Mostek do DQ:** mechanizm Strażnika (progi, alerty) zastosowany do pliku z danymi: plik → reguły → raport.
- **Wątek ofertowy:** kiedy do DQ nie trzeba licencji klasy enterprise. To wprost łączy się z „rekomendacją narzędziową" w audycie.
- **Artefakt:** workflow n8n bez sekretów i identyfikatorów.
- **Do potwierdzenia:** wpis może też opisać ograniczenia (kiedy to za mało).

### 7. Data owner i data steward: kto za co odpowiada (8.12, DG; było 24.11)

- **Szkielet:** różnice ról (owner, steward, custodian) → typowe błędy („wszyscy są właścicielami, więc nikt") → RACI na przykładzie jednego zbioru klientów → jak rozpocząć, gdy nikt nie chce roli.
- **Artefakt:** tabela RACI do skopiowania.
- **CTA:** audyt, bo warsztat z właścicielami danych jest jego elementem.

### 8. LLM w profilowaniu danych: co działa, czego nie robić (15.12, AI → DQ; było 1.12)

- **Mostek do DQ:** LLM pomaga pisać reguły i klasyfikować, ale nie jest miarą jakości (niedeterministyczny, nie liczy dokładnie).
- **Eksperyment:** porównanie reguł napisanych ręcznie i przez LLM na 1000 syntetycznych rekordów. Raportuj trafność i błędy.
- **Zastrzeżenie:** żadnych danych firmowych w promptach i w publikacji.
- **Co z tego dla DQ/DG:** gdzie AI przyspiesza pracę DQ, a gdzie wymaga kontroli człowieka.

### 9. Retencja danych w praktyce: 24 miesiące w Umami i polityki w Kopii (22.12, homelab → DG; było 8.12)

- **Mostek do DG:** retencja jest elementem polityki danych. Pokazujesz własną: Umami (analityka, nagrania sesji), skrzynka `contact@`, kopie zapasowe.
- **Synergia:** wpis powstaje przy okazji wdrożenia retencji, którą polityka prywatności już obiecuje. Najpierw wdróż, potem opisz, a nie odwrotnie.
- **Artefakt:** tabela retencji (kategoria danych, okres, podstawa, mechanizm kasowania) i fragment konfiguracji.
- **Fraza uzupełniająca:** okres przechowywania danych RODO.
- **Tydzień świąteczny:** krótszy, lżejszy wpis jest w porządku.

### 10. Ile kosztują złe dane: prosty model dla firmy średniej wielkości (29.12, DQ; było 15.12)

- **Szkielet:** cztery źródła kosztu (poprawki ręczne, duplikaty, zwroty i reklamacje, decyzje na złych danych) → założenia z zakresami → wynik jako przedział, nie jedna liczba.
- **Artefakt:** arkusz z założeniami do edycji.
- **Zastrzeżenie:** pisz o modelu i założeniach, bez zmyślonych statystyk. Liczby ze źródeł tylko z podanym źródłem.
- **CTA:** audyt („zarząd pyta, ile kosztują złe dane").
- **Domknięcie roku:** to ostatni wpis roku, więc na końcu 5 zdań podsumowania i link do oferty.
- **Tydzień świąteczny:** krótszy, lżejszy wpis jest w porządku.

### 11. Prompty jako dane: wersjonowanie, właściciel, jakość (5.01, AI → DG; było 22.12)

- **Mostek do DG:** prompt używany w procesie to zasób firmy: ma właściciela, wersję, zakres i datę przeglądu. Governance dla promptów to ten sam model co dla danych.
- **Link wewnętrzny:** wpis o promptowaniu.
- **Artefakt:** karta promptu (pola: cel, właściciel, wersja, dane wejściowe, kryteria jakości).

### 12. Data Quality as code: reguły w Git z przeglądem zmian (12.01, homelab → DQ; było 29.12)

- **Mostek do DQ:** reguły jakości w repozytorium: historia zmian, przegląd, testy. Pokazujesz to na swoim kodzie z homelabu.
- **Artefakt:** przykładowe repozytorium reguł (dane syntetyczne).

## Do rozstrzygnięcia przed startem

- **Umowa o pracę.** Tematy 2, 6 i 12 dotykają narzędzi i metod z Twojej pracy. Wpisy mają opierać się na danych syntetycznych i własnych projektach. Zanim zaczniesz publikować o Ataccama czy własnych wdrożeniach, sprawdź umowę (klauzule o konkurencji, własności pracy, poufności).
- **Narzędzia w homelabie.** Założyłem Kopię, n8n, Pi-hole, ZFS, Umami i listmonk (z wcześniejszych rozmów). Popraw, jeśli któreś jest nieaktualne.
- **Tempo.** Wpisy 9 i 10 (22.12 i 29.12) wypadają w okresie świątecznym. Jeśli nie zdążysz, przesuń o tydzień, ale nie rezygnuj z rytmu.
