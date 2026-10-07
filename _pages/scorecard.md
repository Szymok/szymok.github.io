---
layout: page
permalink: /scorecard/
title: Data Quality Scorecard
description: Darmowy arkusz Excel do mierzenia jakości danych w sześciu wymiarach — reguły, progi, semafor i podsumowanie. Szymon Kowalewski.
nav: false
# SZKIELET: usuń poniższą linię po podpięciu formularza zapisu i weryfikacji arkusza
sitemap: false
---

Gotowy arkusz do zmierzenia jakości danych bez zakupu narzędzia. Oparty na [sześciu wymiarach jakości danych](/blog/2026/data-quality-dimensions/): dokładność, kompletność, spójność, aktualność, unikalność i zgodność formatu.

## Co jest w środku

- **Scorecard** — do 50 reguł: wymiar, system, właściciel, próg, liczba rekordów. Wynik i semafor (zielony ≥ 95%, żółty 85–95%, czerwony < 85%) liczą się automatycznie.
- **Podsumowanie** — średni wynik w każdym wymiarze i liczba reguł poniżej progu, w formie widoku dla zarządu.
- **Wymiary** — definicje, wzory metryk i wskazówki pomiarowe.
- **Instrukcja** — jak zacząć od 10 krytycznych reguł.
- Cztery przykładowe reguły (NIP, e-mail, duplikaty, spójność CRM/ERP), które wystarczy nadpisać własnymi.

## Pobierz arkusz

<!--
  Arkusz wysyła mail powitalny z Loops po zapisie (link do /assets/files/data-quality-scorecard.xlsx).
  Link do pliku nie jest podany na tej stronie, aby arkusz był „za bramką”.
  Formularz pojawia się dopiero, gdy w _config.yml ustawiono newsletter.endpoint.
-->

{% if site.newsletter.enabled and site.newsletter.endpoint %}
{% include newsletter.liquid left=true %}
{% else %}
**Formularz zapisu będzie dostępny wkrótce.** Do tego czasu napisz na [hello@skszymon.eu](mailto:hello@skszymon.eu?subject=Data%20Quality%20Scorecard), a odeślę arkusz.
{% endif %}

Podając adres e-mail, zapisujesz się do newslettera i wyrażasz zgodę na otrzymanie arkusza oraz okazjonalnych wiadomości o Data Governance i Data Quality (rzadko, bez spamu). Zgodę możesz wycofać w każdej chwili linkiem w stopce wiadomości. Administratorem danych jest Szymon Kowalewski; szczegóły w [polityce prywatności](/privacy-policy/).

## Potrzebujesz czegoś więcej?

Arkusz mierzy. Jeśli chcesz wiedzieć, **co naprawić najpierw** i jak to wdrożyć, sprawdź [audyt Data Quality](/audyt-data-quality/).
