---
layout: post
title: "Standardy danych: czym są i dlaczego bez nich nie zbudujesz programu DG?"
date: 2024-09-18 23:30:21
description: Czym są standardy danych, jak działają w praktyce i dlaczego interoperacyjność jest kluczowa — analiza na podstawie inicjatywy TransparenCEE.
tags: data-governance data-standards interoperability
categories: data-governance
giscus_comments: true
featured: false
toc:
  sidebar: left
---

# Standardy danych: czym są i dlaczego bez nich nie zbudujesz programu DG?

Kiedy mówię „standardy danych", większość ludzi wyobraża sobie dokumenty ISO leżące gdzieś na serwerze. W rzeczywistości standardy danych to coś dużo bardziej fundamentalnego — to **umowy między ludźmi i systemami co do tego, jak dane powinny wyglądać**, żeby można było nimi się wymieniać, analizować je i ufać im.

Ten artykuł bazuje na analizie przygotowanej w ramach inicjatywy [TransparenCEE](https://transparencee.org/), której celem jest wzmocnienie sektora technologii obywatelskiej w Europie Środkowej i Wschodniej.

---

## Czym właściwie jest standard danych?

Wyobraź sobie pracę magisterską. Ma tytuł, streszczenie, tekst, bibliografię. Jest napisana w ramach programu studiów na konkretnym wydziale, z promotorem i recenzentem. Jest data utworzenia, data obrony, ocena.

Gdybyś chciał zbudować narzędzie do przeglądania prac magisterskich z różnych uczelni, musiałbyś te wszystkie elementy **ustandaryzować** — zdecydować, jakie pola musi mieć każdy rekord, jakie formaty dat akceptujesz, jak identyfikujesz autorów.

Ten proces nazywamy **modelowaniem danych**. I tu zaczyna się standard.

> Modelowanie polega na przekształceniu rzeczywistych bytów w rekordy danych — z jasno zdefiniowanymi wymaganiami, formatami i ograniczeniami.

---

## Od modelu do standardu: interoperacyjność

Sam model to za mało. Standard powstaje wtedy, gdy **wiele organizacji zgadza się stosować ten sam model**. Bez tego mamy silosy — każdy system mówi swoim językiem.

Interoperacyjność to zdolność różnych systemów do wymiany standaryzowanych danych. Żeby to działało, trzeba podjąć decyzje o **reprezentacji danych** — w jakim formacie, w jakiej strukturze.

### Przykłady tego samego rekordu w różnych formatach

**JSON** (preferowany w nowoczesnych API i narzędziach analitycznych):
```json
{
  "author": {"given_name": "Krzysztof", "family_name": "Madejski"},
  "title": "Standardy danych: Czym są i dlaczego są ważne?",
  "date_of_final_accept": "2016-01-29"
}
```

**CSV** (uniwersalny, ale płaski — nie obsługuje zagnieżdżeń):
```
author_given_name, author_family_name, title, date_of_final_accept
Krzysztof, Madejski, Standardy danych: Czym są i dlaczego są ważne?, 2016-01-29
```

**XML** (nadal popularny w administracji publicznej i sektorze finansowym):
```xml
<thesis>
  <author>
    <given_name>Krzysztof</given_name>
    <family_name>Madejski</family_name>
  </author>
  <title>Standardy danych: Czym są i dlaczego są ważne?</title>
  <date_of_final_accept>2016-01-29</date_of_final_accept>
</thesis>
```

Wybór formatu nie jest trywialny — JSON dominuje w sectorze tech, XML w regulowanych branżach (bankowość, ubezpieczenia), a CSV w analityce ad hoc. Warto znać zalety i ograniczenia każdego.

---

## Co czyni standard... standardem?

Gdybym ogłosił „Kowalewski Data Standard 1.0", prawdopodobnie nikt by tego nie zauważył. Siła standardu leży w **adopcji** — jeśli nikt go nie używa, to po prostu nie jest standardem.

Według [World Wide Web Consortium (W3C)](https://www.w3.org/standards/), otwarty standard powinien spełniać te kryteria:

| Kryterium | Opis |
|-----------|------|
| **Przejrzystość** | Proces tworzenia jest publiczny, decyzje dokumentowane |
| **Relewancja** | Standard wynika z realnych potrzeb rynkowych |
| **Otwartość** | Każdy może w nim uczestniczyć |
| **Bezstronność** | Proces decyzyjny jest sprawiedliwy |
| **Dostępność** | Bezpłatny dostęp do specyfikacji |
| **Utrzymanie** | Ciągłe testowanie i aktualizacja |

Dobrym przykładem jest [ISO 3166](https://www.iso.org/iso-3166-country-codes.html) — standard kodów krajów, który jest niewidoczny, ale wszechobecny. Każdy formularz online, który prosi o wybór kraju, prawdopodobnie korzysta z tego standardu.

---

## Otwieranie danych — jak to zrobić dobrze?

Udostępnianie danych innym organizacjom (open data) to kosztowny proces. [Tim Berners-Lee](https://5stardata.info/en/) zaproponował model 5-gwiazdkowy do oceny otwartości danych:

- ⭐ Dane dostępne w internecie (w jakimkolwiek formacie)
- ⭐⭐ Dane w formacie strukturalnym (np. Excel zamiast PDF)
- ⭐⭐⭐ Otwarty format (np. CSV zamiast XLS)
- ⭐⭐⭐⭐ Identyfikatory URI
- ⭐⭐⭐⭐⭐ Powiązane dane (Linked Data)

### Dwa podejścia do udostępniania:

1. **Eksport pliku** — cykliczna publikacja danych (co dzień, co miesiąc). Proste, ale wymaga manualnej obsługi i szybko się dezaktualizuje
2. **API** — programistyczny interfejs pozwalający innym systemom odpytywać dane w czasie rzeczywistym. Bardziej złożone, ale bardziej elastyczne

> **Ważne:** API też powinno być standaryzowane. [OpenAPI Specification](https://www.openapis.org/) to de facto standard opisywania REST API.

---

## Standardy danych w kontekście Data Governance

Dlaczego piszę o standardach w serii o DG? Bo **standardy to kręgosłup programu Data Governance**. Bez standardów:

- Nie zbudujesz wiarygodnego Data Catalog — bo nie wiadomo, jak interpretować dane
- Nie zmierzysz jakości — bo nie ma „złotego wzorca"
- Nie wymieniasz danych — bo każdy system mówi innym językiem
- Nie zapewnisz compliance — bo regulator wymaga konkretnych formatów (np. [XBRL](https://www.xbrl.org/) w raportowaniu finansowym)

Wdrożenie standardów to nie jednorazowe działanie, ale **ciągły proces negocjacji** między zespołami biznesowymi, IT i regulatorami.

---

## Podsumowanie

Standardy danych to fundament, na którym budujemy interoperacyjność, jakość i zaufanie do danych. Bez nich program DG jest jak budynek bez fundamentów — może stoi, ale przy pierwszym wstrząsie się zawali.

Kluczowe wnioski:
- Standard to nie dokument — to **umowa społeczna** między użytkownikami danych
- Format danych (JSON, CSV, XML) ma znaczenie — wybieraj świadomie
- Otwartość standardu decyduje o jego adopcji
- Standardy danych są integralną częścią programu Data Governance

---

### Źródła i dalsze lektury

- TransparenCEE, [*Data Standards Initiative*](https://transparencee.org/)
- W3C, [*Web Standards*](https://www.w3.org/standards/)
- Tim Berners-Lee, [*5 Star Open Data*](https://5stardata.info/en/)
- ISO 3166, [*Country Codes*](https://www.iso.org/iso-3166-country-codes.html)
- OpenAPI Initiative, [*OpenAPI Specification*](https://www.openapis.org/)
- XBRL International, [*eXtensible Business Reporting Language*](https://www.xbrl.org/)