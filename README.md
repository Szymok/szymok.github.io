# skupienie danych

Kod strony [skszymon.eu](https://skszymon.eu): blog o AI, Data Governance i Data Quality oraz self-hostingu, wraz z ofertą audytu jakości danych, scorecardem i narzędziami.

Strona działa na Jekyll i [al-folio](https://github.com/alshedivat/al-folio) (licencja MIT, patrz `LICENSE`), ale treść, układ stron i testy rozwijam po swojemu. Repozytorium jest cienkim starterem: runtime, layouty i funkcje siedzą w gemach (`al_folio_core` i pokrewne), a tutaj są treści, konfiguracja i testy.

## Co gdzie leży

| Ścieżka                                        | Zawartość                                                           |
| ---------------------------------------------- | ------------------------------------------------------------------- |
| `_posts/`                                      | wpisy bloga                                                         |
| `_pages/`                                      | strony: start, oferta, scorecard, test dojrzałości, narzędzia       |
| `assets/files/`                                | pliki do pobrania (skrypty SQL, arkusz Scorecard, dane przykładowe) |
| `docs/content-calendar-2026.md`                | kalendarz wpisów (jeden na tydzień, wtorek) i zasady pisania        |
| `test/integration_*.sh`, `test/visual/`        | testy integracyjne wtyczek i testy przeglądarkowe własnych stron    |
| `AGENTS.md`, `CLAUDE.md`, `docs/BOUNDARIES.md` | zasady dla agentów i podział odpowiedzialności między repo a gemy   |

## Uruchomienie lokalnie

```bash
bundle install
npm ci
bundle exec jekyll serve        # http://localhost:4000/
```

Testy przeglądarkowe (Playwright, własne strony w jasnym i ciemnym motywie, desktop i telefon):

```bash
npx playwright install chromium webkit
npm run test:visual
```

Formatowanie i kontrakt startera przed wypchnięciem zmian:

```bash
npm run lint:prettier
npm run lint:style-contract
```

## Nowy wpis

1. Dodaj `_posts/RRRR-MM-DD-slug.md` z front matterem jak w istniejących wpisach (`layout: post`, `title`, `date`, `description` ok. 150 znaków, `tags`, `categories`, `giscus_comments`, `toc`).
2. Zasady każdego wpisu i plan publikacji: `docs/content-calendar-2026.md`.
3. Dane w przykładach mają być syntetyczne. Pliki do pobrania trafiają do `assets/files/`.

## Licencja

MIT, szczegóły w `LICENSE`. Podstawą jest [al-folio](https://github.com/alshedivat/al-folio).
