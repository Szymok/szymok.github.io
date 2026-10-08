# Plan integracji DQ Profiler ze stroną

Stan na 2026-10-08. Uzupełnia `docs/dq-profiler-plan.md` (plan samego narzędzia). Narzędzie: <https://github.com/Szymok/dq-profiler> (publiczne, MIT, kopia na `git.skszymon.eu/dq-profiler`).

## Cel

Czytelnik wpisu #1 (13.10) i oferty może jednym kliknięciem otworzyć narzędzie, wgrać swój plik CSV i dostać raport, **z zachowaniem obietnicy, że plik nie opuszcza przeglądarki**. Narzędzie jest dowodem kompetencji i prowadzi do audytu.

## Ustalenia z przeglądu repozytorium strony

| Ustalenie | Źródło | Skutek dla integracji |
|---|---|---|
| Strona ma **nagrywanie sesji** Umami (`recorder.js`, próbka 15%, maskowanie `moderate`), ładowane po zgodzie na analitykę | `_includes/head.liquid:224-230`, polityka prywatności pkt 2 | Narzędzie wyświetla zawartość pliku użytkownika w DOM (nazwy kolumn, przykłady błędnych wartości). Maskowanie `moderate` dotyczy pól formularzy, nie tekstu na stronie. **Nagranie mogłoby przechwycić dane z pliku.** Narzędzie nie może działać na stronie z `recorder.js`. |
| **CSP strony jest luźne**: `script-src 'self' 'unsafe-inline' https:`, `connect-src 'self' https:` | `_includes/head.liquid:7-10` | Gwarancja `connect-src 'none'` z narzędzia nie obowiązuje, jeśli narzędzie działa w dokumencie ze stroną. Musi mieć własny dokument z własnym CSP. |
| Analityka (`script.js`, `recorder.js`) jest w `head.liquid`, czyli na każdej stronie z layoutem | `head.liquid` | Każda strona z layoutem `page` ma analitykę (po zgodzie). Dokument bez layoutu jej nie ma. |
| Test dojrzałości jest podstroną z `<script defer src=/assets/js/dq-maturity.js>` i takim samym zapewnieniem „liczy się w przeglądarce" | `_pages/dojrzalosc-dq.md` | Ten wzorzec (JS w assets) jest znany, ale zapewnienie na tamtej stronie jest słabsze: jest tam analityka z nagrywaniem. Warto to doprecyzować w polityce. |
| Statyczne pliki w `assets/` mają domyślnie `sitemap: false`; `purgecss` czyta tylko `_site/assets/css/*.css`; minifikatory mają `compress_css/js: false`, ale `jekyll-terser` przetwarza `.js` | `_config.yml`, `purgecss.config.js` | Aplikacja w `assets/tools/…` nie trafi do sitemapy i nie zostanie przycięta przez purgecss. Terser może zmienić pliki JS po buildzie (do sprawdzenia). |

## Decyzja: wariant A, osobny dokument bez layoutu strony

| Wariant | Opis | Za | Przeciw |
|---|---|---|---|
| **A. Strona opisowa + osobna aplikacja** (rekomendowany) | `/narzedzia/profil-danych/` (layout `page`, analityka po zgodzie) opisuje narzędzie i ma przycisk „Otwórz narzędzie" do `/assets/tools/dq-profiler/` (statyczny `index.html` bez front matter, **bez** `head.liquid`) | brak `recorder.js` i `script.js` w aplikacji, własne CSP wymuszone przez przeglądarkę, najprostsza weryfikacja prywatności, zero zmian w `head.liquid` | aplikacja nie ma nawigacji strony (dodać link powrotny i stopkę), nie mierzymy użycia wewnątrz aplikacji |
| **B. iframe w stronie opisowej** | jak A, ale aplikacja osadzona w ramce | zachowana nawigacja strony | nagrywanie sesji może obejmować ramkę tego samego pochodzenia (nie sprawdzone), analityka strony nadrzędnej w tym samym pochodzeniu może odczytać DOM ramki, wymaga wyłączenia `recorder.js` dla strony (zmiana `head.liquid`) |
| **C. Wbudowanie w stronę** (layout `page` + JS) | jak test dojrzałości | najprostsze wizualnie | **odrzucony:** luźne CSP strony, `recorder.js`, analityka w tym samym dokumencie, obietnica prywatności nie do obrony |

Wariant B można rozważyć później, ale wymaga trzech sprawdzeń, których jeszcze nie wykonano: czy rejestrator Umami obejmuje ramki, czy `iframe sandbox` bez `allow-same-origin` działa z modułami ES i CSP `'self'`, oraz czy pobieranie plików działa w takiej ramce.

## Zakres zmian

### 1. Repozytorium `dq-profiler` (osobny PR)
- Dodać `<meta name="robots" content="noindex">` do `index.html` (indeksowana ma być strona opisowa, nie aplikacja).
- Dodać w aplikacji link powrotny i stopkę z linkiem do strony i oferty (jedna linia, bez śledzenia), bo aplikacja jest bez nawigacji strony.
- Test w `e2e`: w zbudowanym `index.html` nie ma `umami` ani `recorder`, a bundle nie zawiera adresów zewnętrznych poza linkami `<a>`.
- Tag `v0.1.0` i polecenie wydania (`npm run build`), z zapisanym commitem i sumami SHA-256 plików `dist/`.
- Opcja `E2E_BASE_URL` w `playwright.config.ts`: te same testy prywatności uruchamiane na adresie produkcyjnym (smoke test po wdrożeniu).

### 2. Repozytorium strony: aplikacja
- `assets/tools/dq-profiler/` ← zawartość `dist/` wersji `v0.1.0` (commit artefaktu, nie podmoduł).
- `assets/tools/dq-profiler/VERSION`: tag, commit źródłowy, sumy SHA-256.
- Bez SRI: plik jest z tej samej domeny, a `jekyll-terser` może zmienić zawartość JS po buildzie, więc hash nie byłby stabilny. Integralność zapewnia VERSION i test (pkt 5).
- Sprawdzić w `_site/`, że `jekyll-minifier` i `jekyll-terser` nie zmieniają `<meta http-equiv=Content-Security-Policy>` ani działania bundla.

### 3. Repozytorium strony: strona opisowa
- Plik `_pages/narzedzia-profil-danych.md`, `permalink: /narzedzia/profil-danych/`, layout `page`, `nav: false`, pozycja w menu „więcej" (`_pages/dropdown.md`).
- Tytuł i opis pod frazę z kalendarza (np. „profilowanie danych CSV online, jakość danych w przeglądarce"), opis ok. 150 znaków.
- Treść: co robi i czego nie mierzy (trzy z sześciu wymiarów, polskie formaty), jak sprawdzić, że dane nie wychodzą (zakładka Network w narzędziach przeglądarki), limit 25 MB, link do kodu na GitHubie, link do pliku przykładowego `assets/files/klienci-przyklad.csv` (12 wymyślonych rekordów z wpisu #1), przycisk „Otwórz narzędzie", sekcja „Co dalej" z linkami do scorecardu, testu dojrzałości i audytu.
- **Bez analityki dedykowanej narzędziu** (decyzja z 2026-10-08): żadnych zdarzeń Umami ani atrybutów `data-umami-event`. Strona opisowa podlega wyłącznie ogólnej analityce serwisu po zgodzie na pliki cookie, jak każda inna podstrona.
- Opcjonalnie JSON-LD `SoftwareApplication` (darmowa aplikacja webowa).

### 4. Repozytorium strony: polityka prywatności
Nowy punkt (np. „Narzędzie DQ Profiler") w `_pages/privacy-policy.md` z treścią:
- pliki wybrane w narzędziu są przetwarzane wyłącznie w przeglądarce użytkownika i nie są wysyłane na serwer;
- aplikacja nie zawiera analityki, nagrywania sesji ani plików cookie, a przeglądarka blokuje jej połączenia sieciowe;
- strona opisowa podlega zasadom analityki jak reszta serwisu;
- eksportowane raporty zawierają dane z pliku użytkownika i powstają lokalnie, użytkownik decyduje, gdzie je zapisze.

Zaktualizować datę polityki. Doprecyzować też zapewnienie na stronie testu dojrzałości, bo tam działa analityka z nagrywaniem sesji (obecne „może być rejestrowany ogólny przebieg wizyty" jest poprawne, ale warto dodać, że odpowiedzi nie są nagrywane, jeśli maskowanie to gwarantuje; **do zweryfikowania, nie obiecywać bez sprawdzenia**).

### 5. Repozytorium strony: test chroniący przed regresją
Nowy `test/integration_profiler.sh` (dopisany do `unit-tests.yml`), na zbudowanym `_site/`:
- `assets/tools/dq-profiler/index.html` istnieje i zawiera `connect-src 'none'`;
- ten plik **nie zawiera** `umami`, `recorder`, `script.js` ani żadnych adresów `https://` poza dozwolonymi linkami;
- strona opisowa istnieje, nie zawiera `<iframe`, a przycisk wskazuje na `/assets/tools/dq-profiler/`;
- sumy SHA-256 plików z `VERSION` zgadzają się z plikami w `_site/`.
To jest odpowiednik zasady „narzędzie nie może nigdy dostać analityki", zapisany jako test.

### 6. Linki (po wdrożeniu punktów 2–5)
- Wpis #1 (`_posts/2026-10-13-kompletnosc-danych-sql.md`), sekcja „Co dalej": link do narzędzia z dopiskiem, że liczy te same wskaźniki na pliku czytelnika.
- Strona oferty `/audyt-data-quality/` i scorecard: jedna linia „Sprawdź własny plik".
- Menu „więcej": pozycja „profil danych CSV".
- Wpis na LinkedIn w dniu 13.10 powinien wskazywać wpis, a wpis narzędzie.

## Kolejność i terminy

Wpis #1 publikuje się **13.10 o 08:00 UTC**, a dziś jest 8.10. Link ze wpisu do narzędzia wymaga, żeby narzędzie było wcześniej na produkcji.

| Krok | Zakres | Szacunek |
|---|---|---|
| 1 | PR w `dq-profiler`: noindex, link powrotny i stopka, testy braku analityki, tag `v0.1.0`, `E2E_BASE_URL` | 0,5 dnia |
| 2 | PR w repo strony: aplikacja, VERSION, strona opisowa, plik przykładowy, menu, polityka prywatności, test integracyjny | 1 dzień |
| 3 | Weryfikacja na produkcji: testy Playwright przeciw adresowi produkcyjnemu, Network, Lighthouse | 0,25 dnia |
| 4 | PR z linkami: wpis #1, oferta, scorecard | 0,25 dnia |
| **Razem** | | **ok. 2 dni robocze** |

Cel: kroki 1–3 zakończone do 11–12.10, krok 4 przed 13.10. Jeśli się nie uda, wpis #1 publikuje się bez linku do narzędzia (nie blokować wpisu).

## Kryteria sukcesu

1. Na produkcji aplikacja nie wykonuje żadnych żądań poza ładowaniem własnych plików (test Playwright na adresie produkcyjnym).
2. Dokument aplikacji nie zawiera `recorder.js` ani `script.js` Umami (test integracyjny).
3. Na stronie opisowej Lighthouse: dostępność ≥ 95, brak regresji wydajności strony głównej.
4. `/assets/tools/dq-profiler/` nie występuje w `sitemap.xml`, strona opisowa występuje.
5. Polityka prywatności opisuje narzędzie przed jego wdrożeniem (kolejność scalania: polityka razem z aplikacją, nigdy po).
6. Po 30 dniach: liczba wizyt strony opisowej w ogólnych statystykach Umami (bez zdarzeń) i przynajmniej jedno zapytanie o audyt z odniesieniem do narzędzia, zgłoszone e-mailem (cel orientacyjny przy obecnym ruchu). Użycia samej aplikacji nie mierzymy.

## Pre-mortem

| Ryzyko | Skutek | Środek zaradczy |
|---|---|---|
| Ktoś później doda aplikację do layoutu lub dołączy `head.liquid` | nagrywanie sesji obejmuje dane z pliku | test integracyjny z pkt 5, komentarz w repo |
| `jekyll-minifier` lub `jekyll-terser` zmienia `index.html` lub bundle (np. usuwa meta CSP) | utrata CSP, błędne działanie | sprawdzenie w `_site/` i test integracyjny na zbudowanej stronie |
| Artefakt w repo strony rozjeżdża się ze źródłem | nie wiadomo, jaka wersja działa | VERSION z commitem i sumami, test sum |
| Ścieżki względne zawodzą bez końcowego `/` (`/assets/tools/dq-profiler`) | pusta strona | linkować zawsze z `/`, test sprawdzający odpowiedź 200 dla obu wariantów, nie zakładać zachowania hostingu bez sprawdzenia |
| Pamięć podręczna Cloudflare/GitHub Pages (10 min) pokazuje starą wersję | niezgodność plików | nazwy plików z hashem w `assets/`, `index.html` krótko w cache, sprawdzenie z parametrem omijającym cache |
| Polityka prywatności mówi o narzędziu zanim zostanie ono wdrożone, lub odwrotnie | niezgodność z RODO | scalać razem w jednym PR |
| Nowy użytkownik nie wie, że to tylko trzy wymiary i polskie formaty | zawyżone oczekiwania | opis na stronie i w raporcie, link do audytu |
| Brak analityki w aplikacji: nie wiemy, ilu osób faktycznie korzysta | brak danych do decyzji o rozwoju | mierzyć wyłącznie ogólne wizyty strony opisowej; nie dodawać do aplikacji ani do przycisku żadnej analityki (świadoma decyzja) |

## Devil's Advocate

- **Wariant A odcina narzędzie od strony.** Użytkownik trafia na gołą aplikację bez menu i może się zgubić. Link powrotny i stopka łagodzą to, ale nie eliminują.
- **Nie mierzymy użycia.** Przyjęta cena prywatności. Jeśli kiedyś trzeba będzie mierzyć użycie, jedyną opcją zgodną z obietnicą są zdarzenia bez zawartości pliku, a to wymaga osobnej decyzji i zmiany polityki.
- **Dwa miejsca prawdy.** Kod jest w osobnym repo, a artefakt w repo strony. To koszt utrzymania, który ma sens tylko wtedy, gdy narzędzie jest rozwijane. Przy braku rozwoju prościej byłoby trzymać je wyłącznie w repo strony (ale tracimy odrębne repozytorium jako portfolio).
- **Wersja produkcyjna i test na produkcji.** Test Playwright na adresie produkcyjnym wymaga dostępu do sieci i może zostać zablokowany przez Cloudflare. Trzeba sprawdzić.

## Decyzje (2026-10-08)

1. **Ścieżka aplikacji:** `/assets/tools/dq-profiler/` (a nie `/narzedzia/profil-danych/app/`). Strona opisowa zostaje pod `/narzedzia/profil-danych/`.
2. **Analityka:** żadnej analityki związanej z narzędziem, ani w aplikacji, ani zdarzeń na przycisku.

## Pytania otwarte

1. Czy po stronie opisowej ma być też osadzony film lub zrzut ekranu (waga dla wydajności strony)?
2. Czy plik przykładowy `klienci-przyklad.csv` ma być osobnym zasobem do pobrania, czy wystarczy link do repozytorium? (Rekomendacja: osobny plik, bo czytelnik może od razu przetestować narzędzie bez własnych danych.)
