---
layout: page
permalink: /audyt-data-quality/
title: Audyt jakości danych (Data Quality)
description: "Audyt jakości danych dla firm średniej wielkości: pomiar w sześciu wymiarach, priorytety i plan na 90 dni. Stała cena, raport w kilka tygodni. Szymon Kowalewski, Data Governance Specialist."
nav: true
nav_order: 2
nav_title: oferta
---

<div class="offer-hero">
  <p class="offer-lead">Zanim zaczniesz naprawiać dane, sprawdź, jak bardzo są zepsute.</p>
  <p>Mierzę jakość danych w Twojej firmie w sześciu wymiarach, wskazuję, co naprawić najpierw, i zostawiam plan na 90 dni. Stała cena, raport w kilka tygodni, bez kupowania licencji.</p>
  <p class="offer-actions">
    <a class="offer-btn" href="mailto:hello@skszymon.eu?subject=Audyt%20Data%20Quality">Umów rozmowę</a>
    <a class="offer-btn offer-btn-ghost" href="/dojrzalosc-dq/">Zrób test dojrzałości (5 min)</a>
  </p>
</div>

## Objawy, z którymi firmy do mnie trafiają

Złe dane rzadko wyglądają jak "złe dane". Zwykle wyglądają jak sprzeczne raporty, zawyżona sprzedaż albo mail, który wraca. Za każdym objawem stoi konkretny wymiar jakości i konkretny sposób pomiaru.

| Co widać w firmie | Wymiar | Jak to sprawdzam |
|---|---|---|
| Dwa raporty pokazują różne liczby dla tego samego wskaźnika | Spójność | porównanie wartości między systemami i raportami |
| Ten sam klient występuje pod kilkoma nazwami, a sprzedaż jest zawyżona | Unikalność | wykrywanie duplikatów po kluczach biznesowych |
| W bazie brakuje telefonów, adresów e-mail i numerów NIP | Kompletność | odsetek wypełnionych pól wymaganych |
| Adresy bez „@”, daty z przyszłości, kody pocztowe w złym formacie | Zgodność formatu | reguły walidacyjne z progiem akceptacji |
| Stare dane uchodzą za bieżące | Aktualność | wiek rekordów i opóźnienie względem źródła |
| Nikt nie umie powiedzieć, czy dane zgadzają się z rzeczywistością | Dokładność | porównanie ze źródłem referencyjnym i próbkowanie |

Do tego dochodzi problem, którego nie widać w tabelach: brak właścicieli danych, spisanych reguł i uzgodnionych progów. Audyt obejmuje także ten obszar, bo bez niego nikt nie naprawi tego, co wykryje pomiar. Wymiary opisuję szerzej w artykule [Wymiary jakości danych](/blog/2026/data-quality-dimensions/).

## Jak wygląda audyt

| Etap | Co się dzieje | Czas |
|------|---------------|------|
| 1. Rozmowa wstępna | Cele, systemy, wybór zbiorów do audytu; bezpłatnie | 45–60 min |
| 2. Umowa i dostęp | Umowa o poufności, dostęp tylko do odczytu lub próbki danych | 3–5 dni |
| 3. Pomiar | Przegląd struktur, profilowanie, szkic reguł i metryk | 1–2 tygodnie |
| 4. Warsztat z właścicielami danych | Weryfikacja wyników, ustalenie progów i odpowiedzialności | 2 h |
| 5. Raport i prezentacja | Scorecard, priorytety, plan na 90 dni | 1 tydzień |

Prowadzę audyty równolegle z pracą etatową, dlatego terminy podaję w tygodniach, a nie w dniach roboczych. Dzięki temu są realne.

## Trzy pakiety

| | **Mini-audyt** | **Audyt standardowy** | **Audyt + start wdrożenia** |
|---|---|---|---|
| Dla kogo | pierwszy pomiar jednego obszaru | cała firma lub dział, kilka systemów | firma gotowa wdrażać od razu |
| Zakres danych | 1 zbiór / system | do 3 zbiorów | do 3 zbiorów |
| Reguły jakości | do 10 | do 20 | do 20 + konfiguracja pierwszych |
| Scorecard w 6 wymiarach | tak | tak | tak |
| Lista priorytetów | tak | tak | tak |
| Warsztat z właścicielami danych | — | tak (2 h) | tak (2 h) |
| Plan wdrożenia na 90 dni | skrót | pełny | pełny |
| Rekomendacja narzędziowa | — | tak | tak |
| Podsumowanie dla zarządu (1 strona) | tak | tak | tak |
| Wsparcie po audycie | — | — | 2 sesje po 90 min |
| Czas realizacji | 2–3 tygodnie | 4–6 tygodni | 6–8 tygodni |
| **Cena netto** | **od 3 500 zł** | **od 9 000 zł** | **od 15 000 zł** |

**Nie wiesz, który wybrać?** Zacznij od mini-audytu. Jego cena jest zaliczana na poczet audytu standardowego, jeśli zdecydujesz się na niego w ciągu 60 dni. Cena jest stała i ustalana przed startem na podstawie liczby systemów i dostępnych danych. Nie rozliczam godzin ani nie przedłużam pracy bez Twojej zgody.

**Pilotaż.** Dla dwóch pierwszych firm cena jest niższa o 30% w zamian za zgodę na anonimowe studium przypadku (bez nazwy firmy, bez danych) i krótką opinię po zakończeniu. Zapytaj o dostępność.

## Co dostajesz

1. **Scorecard jakości danych**: pomiar w sześciu wymiarach dla wybranych zbiorów, w formie semafora (zielony od 95%, żółty 85–95%, czerwony poniżej 85%).
2. **Listę priorytetów**: najważniejsze reguły jakości z progami akceptacji i proponowanymi właścicielami.
3. **Plan wdrożenia**: kolejność działań, role (data owner, data steward) i szacunek pracochłonności.
4. **Rekomendację narzędziową** (pakiety Standard i Start): co wystarczy zrobić w istniejącym stosie, a gdzie sensowne jest dedykowane narzędzie, niezależnie od dostawcy.
5. **Podsumowanie dla zarządu**: jedna strona ze stanem, ryzykami, kosztem bezczynności i proponowanymi krokami.

## Kiedy to ma sens, a kiedy nie

**Audyt ma sens, gdy:**
- raporty się nie zgadzają, a nikt nie wie dlaczego,
- planujesz wdrożyć narzędzie Data Quality lub MDM i potrzebujesz stanu wyjściowego,
- zbliża się migracja systemu albo projekt AI na własnych danych,
- zarząd pyta, ile naprawdę kosztują złe dane.

**Audyt nie jest dla Ciebie, gdy:**
- szukasz wdrożenia konkretnego narzędzia (to osobny projekt, który wyceniam po audycie),
- wszystkie dane leżą w jednym małym systemie, a problem da się rozwiązać jednym zapytaniem SQL,
- nikt w firmie nie może przyjąć roli właściciela danych. Wtedy najpierw trzeba to ustalić i mogę w tym pomóc.

## Jak oceniam sukces

Każdy audyt zaczyna się od wyniku wyjściowego, bo bez niego nie da się uczciwie powiedzieć, czy jest lepiej. W raporcie dostajesz trzy liczby: wynik w każdym wymiarze, liczbę reguł poniżej uzgodnionego progu i listę właścicieli z terminami. Po 90 dniach można powtórzyć pomiar i porównać go z punktem wyjścia.

## Co możesz sprawdzić, zanim napiszesz

Jestem Data Governance Specialist. Na co dzień zarządzam obszarem Data Governance i Data Quality, pracuję z platformą Ataccama ONE i wdrażam reguły jakości, katalog danych oraz procesy Master Data Management. Wcześniej pracowałem jako Data Consultant i Data Engineer. Zamiast listy klientów pokazuję to, co możesz zobaczyć sam:

- [blog o Data Governance i Data Quality](/blog/), na przykład [wybór platformy Ataccama](/blog/2025/ataccama/) i [standardy danych](/blog/2024/dg-standars/),
- [ogród wiedzy](/garden/) z notatkami roboczymi,
- [test dojrzałości Data Quality](/dojrzalosc-dq/), który dziś daje Ci wynik w 6 obszarach,
- [arkusz Scorecard](/scorecard/), na którym zmierzysz pierwszy zbiór samodzielnie.

<!-- Dodaj tu 1–2 zdania o konkretnych wynikach z wdrożeń, jeśli możesz je ujawnić (liczby, branża). Nie wpisuj niczego, czego nie możesz udokumentować. -->

## Dane i poufność

- Pracuję na dostępie tylko do odczytu i na próbkach, jeśli to wystarczy do celu audytu.
- Przed startem podpisujemy umowę o zachowaniu poufności.
- Dane osobowe przetwarzam wyłącznie na podstawie umowy powierzenia, jeśli ich zakres tego wymaga.
- Wyniki i dane nie opuszczają Twojego środowiska, o ile nie uzgodnimy inaczej.

## Najczęstsze pytania

**Czy muszę mieć narzędzie Data Quality?** Nie. Audyt działa na istniejących źródłach i zapytaniach. Rekomendacja narzędzia jest jednym z rezultatów, nie warunkiem.

**Co jeśli wyniki będą złe?** To normalne, bo większość organizacji ma dane gorsze, niż zakłada. Celem jest ustalenie, co naprawić najpierw, a nie ocena ludzi.

**Czy pomożesz we wdrożeniu?** Tak, jako osobne zlecenie po audycie albo w pakiecie "Audyt + start wdrożenia". Zakres wyceniam indywidualnie.

**Czy możemy zacząć od mini-audytu i rozszerzyć go później?** Tak. Cena mini-audytu jest zaliczana na poczet audytu standardowego, jeśli zdecydujesz się na niego w ciągu 60 dni.

**Dlaczego mini-audyt kosztuje od 3 500 zł?** Cena obejmuje 16–20 godzin pracy: profilowanie, reguły, scorecard i raport. Dokładną wycenę podaję po rozmowie wstępnej.

## Umów rozmowę

Napisz na [hello@skszymon.eu](mailto:hello@skszymon.eu?subject=Audyt%20Data%20Quality) z krótkim opisem: jakie systemy, jaki problem, jaki termin. Odpowiadam w ciągu 2 dni roboczych.

<style>
  .offer-hero { margin: 0 0 2rem; padding: 1.5rem; border: 1px solid color-mix(in srgb, currentColor 18%, transparent); border-left: 6px solid var(--global-theme-color, #4f46e5); border-radius: 8px; }
  .offer-lead { margin: 0 0 0.5rem; font-size: 1.5rem; font-weight: 700; line-height: 1.25; }
  .offer-actions { display: flex; flex-wrap: wrap; gap: 0.75rem; margin: 1.25rem 0 0; }
  .offer-btn { display: inline-block; padding: 0.6rem 1.2rem; border: 2px solid var(--global-theme-color, #4f46e5); border-radius: 6px; background: var(--global-theme-color, #4f46e5); color: #fff; font-weight: 600; text-decoration: none; }
  .offer-btn:hover, .offer-btn:focus-visible { filter: brightness(1.12); color: #fff; text-decoration: none; }
  .offer-btn-ghost { background: transparent; color: var(--global-theme-color, #4f46e5); }
  .offer-btn-ghost:hover, .offer-btn-ghost:focus-visible { color: var(--global-theme-color, #4f46e5); background: color-mix(in srgb, var(--global-theme-color, #4f46e5) 10%, transparent); }
</style>
<script type="application/ld+json">
{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[
{"@type":"Question","name":"Czy muszę mieć narzędzie Data Quality?","acceptedAnswer":{"@type":"Answer","text":"Nie. Audyt działa na istniejących źródłach i zapytaniach. Rekomendacja narzędzia jest jednym z rezultatów, nie warunkiem."}},
{"@type":"Question","name":"Co jeśli wyniki będą złe?","acceptedAnswer":{"@type":"Answer","text":"To normalne, bo większość organizacji ma dane gorsze, niż zakłada. Celem jest ustalenie, co naprawić najpierw, a nie ocena ludzi."}},
{"@type":"Question","name":"Czy pomożesz we wdrożeniu?","acceptedAnswer":{"@type":"Answer","text":"Tak, jako osobne zlecenie po audycie albo w pakiecie Audyt + start wdrożenia. Zakres wyceniam indywidualnie."}},
{"@type":"Question","name":"Czy możemy zacząć od mini-audytu i rozszerzyć go później?","acceptedAnswer":{"@type":"Answer","text":"Tak. Cena mini-audytu jest zaliczana na poczet audytu standardowego, jeśli zdecydujesz się na niego w ciągu 60 dni."}},
{"@type":"Question","name":"Dlaczego mini-audyt kosztuje od 3 500 zł?","acceptedAnswer":{"@type":"Answer","text":"Cena obejmuje 16–20 godzin pracy: profilowanie, reguły, scorecard i raport. Dokładną wycenę podaję po rozmowie wstępnej."}}
]}
</script>
