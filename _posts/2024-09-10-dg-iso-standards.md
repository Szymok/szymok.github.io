---
layout: post
title: "Które normy ISO stosować w Data Governance? Praktyczny przegląd"
date: 2024-09-10 22:19:50
description: Przegląd standardów ISO przydatnych w programie Data Governance — od jakości danych (ISO 8000) po bezpieczeństwo informacji (ISO 27001).
tags: data-governance data-standards iso-standards
categories: data-governance
giscus_comments: true
featured: false
toc:
  sidebar: left
---

# Które normy ISO stosować w Data Governance?

Standardy ISO mogą brzmieć jak biurokratyczny koszmar, ale w programie Data Governance pełnią realną funkcję — dają **audytowalny punkt odniesienia** dla regulatorów, zarządu i partnerów biznesowych. Zamiast wymyślać koło od nowa, możesz oprzeć się na sprawdzonych frameworkach.

W tym artykule przeglądam normy ISO, które najczęściej pojawiają się w kontekście zarządzania danymi. Nie musisz wdrażać ich wszystkich — ale warto wiedzieć, jakie masz opcje.

---

## ISO 8000 — jakość danych

[ISO 8000](https://www.iso.org/standard/81745.html) to seria standardów poświęcona wyłącznie **jakości danych**. Obejmuje wymiary takie jak:

- **Składnia** — czy dane mają poprawny format?
- **Pochodzenie** — skąd dane się wzięły?
- **Kompletność** — czy wszystkie wymagane pola są wypełnione?
- **Dokładność** — czy dane odzwierciedlają rzeczywistość?

ISO 8000 składa się z kilku części. Na przykład:
- **ISO 8000-110** — określa wymagania dotyczące wymiany danych bazowych (Master Data)
- **ISO 8000-115:2018** — definiuje zasady tworzenia identyfikatorów w zarządzaniu danymi bazowymi, np. w katalogach produktów
- **ISO 8000-120** — specyfikuje wymagania dotyczące pochodzenia (provenance) danych

Normą zarządza komitet techniczny [ISO TC 184/SC 4](https://www.iso.org/committee/54158.html) (Dane przemysłowe). W praktyce jest bardziej popularna w sektorach produkcyjnych i logistycznych, ale jej zasady mają znaczenie universalne.

---

## ISO/IEC 38505-1:2017 — governance danych

[ISO/IEC 38505-1:2017](https://www.iso.org/standard/56639.html) to standard, który **wprost adresuje Data Governance** jako część szerszego governance IT. Kluczowe założenia:

- Zarządzanie danymi to **podzbiór zarządzania IT**, które jest z kolei częścią zarządzania organizacją
- Definiuje odpowiedzialności **organu zarządzającego** (np. zarządu) za dane
- Nacisk na *efektywne, skuteczne i akceptowalne* wykorzystanie danych

Dlaczego jest ważny? Bo mówi wprost: **odpowiedzialność za dane spoczywa na zarządzie**, nie na IT. To potężny argument, kiedy próbujesz uzyskać sponsoring C-level dla programu DG.

> **Uwaga:** ISO 38505 to zbiór wytycznych (guidelines), nie wymagań — co oznacza, że **nie można się z niego certyfikować**. To odróżnia go od np. ISO 27001.

---

## ISO 22745 — wymiana danych bazowych

[ISO 22745](https://www.iso.org/standard/73283.html) jest mniej znany, ale istotny w środowiskach, gdzie wymiana Master Data między organizacjami jest kluczowa (np. łańcuch dostaw, obronność). Standard wywodzi się z [NATO Codification System (NCS)](https://www.nato.int/cps/en/natohq/topics_69349.htm) i definiuje:

- Wymagania dotyczące **składni** przekazów z danymi bazowymi
- **Kodowanie semantyczne** — zapewnienie, że termin „śruba M8" znaczy to samo w Polsce i w Niemczech
- **Przenośność** danych między systemami różnych dostawców

---

## ISO 3166 — dane referencyjne

Pozornie prosty, ale [ISO 3166](https://www.iso.org/iso-3166-country-codes.html) jest jednym z najszerzej stosowanych standardów na świecie. Definiuje kody dla nazw krajów:

- `PL` = Polska
- `DE` = Niemcy
- `US` = Stany Zjednoczone

W kontekście DG, implementacja standardowych danych referencyjnych (Reference Data Management) to jedno z najłatwiejszych „quick wins" — zastąpienie chaotycznych wpisów typu „Polska", „PL", „POL", „Poland" jednym kodem ISO.

---

## ISO/IEC 11179 — rejestr metadanych

[ISO/IEC 11179](https://www.iso.org/standard/78915.html) to standard rejestru metadanych (Metadata Registry — MDR). W siedmiu częściach definiuje ramy do **opisu, organizacji i wymiany metadanych** w organizacji.

Dobrym przykładem zastosowania jest australijski [METeOR (Metadata Online Registry)](https://meteor.aihw.gov.au/) prowadzony przez Australian Institute of Health and Welfare — kompletny rejestr metadanych oparty na ISO 11179, który pozwala zrozumieć definicje danych zdrowotnych w całym kraju.

---

## ISO 27001:2022 — bezpieczeństwo informacji

[ISO 27001:2022](https://www.iso.org/standard/27001) to międzynarodowy standard dla **systemów zarządzania bezpieczeństwem informacji (ISMS)**. Choć to standard z domeny security, nie DG, oba obszary mają silne powiązania:

### Gdzie Data Governance spotyka ISO 27001?

| Obszar | Rola DG | Wymaganie ISO 27001 |
|--------|---------|---------------------|
| **Klasyfikacja danych** | DG definiuje, co jest „wrażliwe" | ISO 27001 wymaga klasyfikacji do zastosowania odpowiednich zabezpieczeń |
| **Kontrola dostępu** | DG ustala, kto jest właścicielem danych | ISO 27001 wymaga ograniczenia dostępu do autoryzowanych osób |
| **Zarządzanie ryzykiem** | DG identyfikuje krytyczne zasoby danych | ISO 27001 wymaga oceny ryzyk i odpowiednich zabezpieczeń |
| **Audyt** | DG utrzymuje rejestr polityk i zmian | ISO 27001 wymaga regularnych audytów wewnętrznych i zewnętrznych |
| **Reagowanie na incydenty** | DG ułatwia identyfikację zakresu naruszenia | ISO 27001 wymaga formalnego zarządzania incydentami |
| **Szkolenia** | DG buduje świadomość wartości danych | ISO 27001 kładzie nacisk na edukację pracowników |

**Kluczowe:** ISO 27001 jest jednym z niewielu standardów, z którego **można uzyskać certyfikat**. Dojrzałość Data Governance znacząco ułatwia spełnienie jego wymagań.

---

## Którą normę wybrać na start?

Nie musisz wdrażać wszystkich naraz. Moja rekomendacja:

1. **Zacznij od ISO 38505** — daje ramę organizacyjną dla programu DG
2. **Równolegle wdrażaj ISO 8000** — konkretne wymiary jakości danych
3. **Użyj ISO 3166 i podobnych** — szybkie wdrożenie standardowych danych referencyjnych (quick win)
4. **ISO 27001 wdróż, gdy masz budżet** — certyfikacja to inwestycja, ale ROI jest jasne (zgodność regulacyjna)

---

## Podsumowanie

Standardy ISO to nie cel sam w sobie — to **narzędzia budujące wiarygodność** programu Data Governance. Dają Ci gotowe ramy, audytowalną zgodność i wspólny język z regulatorami.

Pamiętaj:
- Certyfikacja jest możliwa tylko dla standardów z **wymaganiami** (np. ISO 27001), nie dla wytycznych (np. ISO 38505)
- Nie próbuj wdrażać wszystkiego naraz — **zacznij od tego, co daje wartość biznesową**
- Standardy ISO najlepiej działają w połączeniu z frameworkami branżowymi (DAMA DMBOK, DGI)

---

### Źródła i dalsze lektury

- ISO 8000, [*Data Quality*](https://www.iso.org/standard/81745.html)
- ISO/IEC 38505-1:2017, [*Governance of Data*](https://www.iso.org/standard/56639.html)
- ISO 22745, [*Industrial Data — Open Technical Dictionaries*](https://www.iso.org/standard/73283.html)
- ISO 3166, [*Country Codes*](https://www.iso.org/iso-3166-country-codes.html)
- ISO/IEC 11179, [*Metadata Registries*](https://www.iso.org/standard/78915.html)
- ISO 27001:2022, [*Information Security Management Systems*](https://www.iso.org/standard/27001)
- Australian Institute of Health and Welfare, [*METeOR Metadata Registry*](https://meteor.aihw.gov.au/)