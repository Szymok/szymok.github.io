---
layout: post
title: Wstęp do Data Governance
date: 2024-08-21 21:55:10
description: Od czego zacząć przygodę z zarządzaniem danymi? Kluczowe elementy, role i wyzwania — z perspektywy praktyka.
tags: data-governance data-management data-quality data-stewardship
categories: data-governance
giscus_comments: true
featured: false
toc:
  sidebar: left
---

# Wstęp do Data Governance — od czego zacząć?

Kiedy zaczynałem swoją drogę w Data Governance, największym zaskoczeniem było to, jak mało ten temat dotyczy technologii, a jak bardzo — **ludzi i procesów**. Zarządzanie danymi to nie kolejne narzędzie IT — to zmiana sposobu myślenia o danych w całej organizacji.

Ten post jest początkiem serii, w której chcę pokazać Data Governance z perspektywy praktyka — nie podręcznikowej teorii, a realnych doświadczeń.

---

## Co tak naprawdę oznacza Data Governance?

Według [DAMA International](https://www.dama.org/cpages/body-of-knowledge), Data Governance to *„sprawowanie władzy, kontroli i wspólnego podejmowania decyzji dotyczących zarządzania zasobami danych"*. Brzmi akademicko, ale w praktyce sprowadza się do prostego pytania: **kto jest odpowiedzialny za dane i jak zapewniamy, że są wiarygodne?**

Wiele organizacji traktuje dane jako „rzecz IT". Dział IT odpowiada za serwery i bazy danych, więc chyba odpowiada też za „dane"? To fundamentalny błąd. Dane to **zasób biznesowy** — analogicznie jak finanse (których nie zarządza dział IT, tylko CFO).

> *„Data Governance is about behavior — creating the organizational behaviors around how data is managed."*  
> — [John Ladley, „Data Governance: How to Design, Deploy, and Sustain an Effective Data Governance Program"](https://www.amazon.com/Data-Governance-Design-Deploy-Sustain/dp/0124158293)

---

## Trzy filary, od których zaczyna się każdy program DG

Na podstawie frameworku [DMBOK2 (Data Management Body of Knowledge)](https://www.dama.org/cpages/body-of-knowledge) oraz [Data Governance Institute](https://datagovernance.com/the-data-governance-basics/), program Data Governance opiera się na trzech filarach:

### 1. Ludzie — role i odpowiedzialności

Bez jasnego przypisania odpowiedzialności, nikt nie czuje się „właścicielem" danych. Kluczowe role to:

- **Data Owner** — osoba biznesowa odpowiedzialna za dany obszar danych (np. dyrektor sprzedaży jest ownerem danych sprzedażowych)
- **Data Steward** — operacyjny opiekun jakości danych w danym obszarze. To ta osoba, która na co dzień pilnuje, że dane są poprawne i spójne
- **Data Governance Council** — komitet decyzyjny, który ustala priorytety i rozstrzyga konflikty

W mojej praktyce widzę, że organizacje najczęściej potykają się na tym etapie — nikt nie chce być „tym od danych", bo to dodatkowa odpowiedzialność bez jasnych korzyści. Zmiana tego nastawienia wymaga wsparcia zarządu.

### 2. Procesy — polityki i standardy

Polityki to nie dokumenty leżące na półce — to żywe zasady, które muszą być egzekwowane. Kluczowe obszary to:

- **Klasyfikacja danych** — które dane są publiczne, a które poufne?
- **Kontrola dostępu** — kto i do jakich danych ma dostęp?
- **Zarządzanie zmianą** — jak wprowadzamy zmiany w definicjach i strukturach danych?
- **Jakość danych** — jakie metryki DQ mierzymy i kto reaguje na problemy?

[ISO/IEC 38505-1:2017](https://www.iso.org/standard/56639.html) dostarcza ram dla zarządzania danymi jako elementu governance IT. Warto się z nim zapoznać, bo mówi wprost o odpowiedzialności zarządu za dane — a każdy Data Owner lubi się dowiedzieć, że to nie „dodatkowe zadanie", a odpowiedzialność wynikająca z międzynarodowego standardu.

### 3. Technologia — narzędzia wspierające

Technologia jest **ostatnia**, nie pierwsza. To częsty błąd: kupujemy narzędzie, a potem szukamy do niego procesu. Narzędzia wspierające DG to m.in.:

- **Data Catalog** — centralna baza wiedzy o danych (np. [Ataccama](https://www.ataccama.com/), [Collibra](https://www.collibra.com/), [Alation](https://www.alation.com/))
- **Data Quality engines** — narzędzia do profilowania, czyszczenia i monitorowania jakości
- **Data Lineage** — śledzenie przepływu danych przez systemy
- **Business Glossary** — słownik terminów biznesowych zapewniający spójne rozumienie danych

---

## Wyzwania, które spotkasz na starcie

Każdy program DG napotyka te same bariery. [Gartner](https://www.gartner.com/en/information-technology/glossary/data-governance) raportuje, że do 2025 roku 80% organizacji próbujących skalować biznes oparty na danych poniesie porażkę z powodu braku nowoczesnego podejścia do Data Governance.

### Opór zmian

Ludzie przyzwyczajeni do „swoich Exceli" nie chcą, żeby ktoś wchodził im w dane. Kluczem jest **komunikacja korzyści**: „Data Governance nie zabiera Ci danych — sprawia, że możesz im ufać."

### Brak szybkich wyników

DG to maraton, nie sprint. Efekty widać po miesiącach, a zarząd chce ROI po kwartale. Warto więc zacząć od **quick wins** — np. oczyszczenie duplikatów klientów, które od razu da mierzalny efekt.

### Zbyt szeroki zakres na start

Próba objęcia programem DG wszystkich systemów i danych naraz to recepta na porażkę. Lepiej zacząć od **jednego domeny danych** (np. dane klientów) i rozszerzać.

---

## Od czego zacząć? Moja rekomendacja

Na podstawie frameworku [DGI (Data Governance Institute)](https://datagovernance.com/) i własnych doświadczeń, proponuję taki start:

1. **Zidentyfikuj sponsora** — bez wsparcia na poziomie C-level program DG nie przetrwa
2. **Wybierz jedną domenę danych** — np. dane klientów lub dane produktowe
3. **Zmapuj obecny stan** — kto jest właścicielem? Jakie systemy przechowują te dane? Jak wygląda jakość?
4. **Zdefiniuj 5-10 kluczowych reguł** — zaczynaj od mała, ale od rzeczy mierzalnych
5. **Mierz i raportuj** — pokaż postęp na dashboardzie, nie w raporcie na 50 stron

---

## Podsumowanie

Data Governance to nie projekt z datą zakończenia — to **ciągły proces**. Rozpoczynając, warto pamiętać, że:

- **Ludzie > procesy > technologia** — w tej kolejności
- **Quick wins budują momentum** — pokaż wartość wcześnie
- **Komunikacja jest kluczem** — DG musi mieć sens dla biznesu, nie tylko dla IT

W następnych postach w tej serii zajmę się konkretnymi frameworkami i standardami ISO, które pomagają nadać programowi DG strukturę.

---

### Źródła i dalsze lektury

- DAMA International, [*DMBOK2: Data Management Body of Knowledge*](https://www.dama.org/cpages/body-of-knowledge), 2017
- John Ladley, [*Data Governance: How to Design, Deploy, and Sustain an Effective Data Governance Program*](https://www.amazon.com/Data-Governance-Design-Deploy-Sustain/dp/0124158293), 2nd Edition, 2019
- Data Governance Institute, [*The DGI Data Governance Framework*](https://datagovernance.com/the-data-governance-basics/)
- ISO/IEC 38505-1:2017, [*Information technology — Governance of IT — Governance of data*](https://www.iso.org/standard/56639.html)
- Gartner, [*Data Governance Definition*](https://www.gartner.com/en/information-technology/glossary/data-governance)