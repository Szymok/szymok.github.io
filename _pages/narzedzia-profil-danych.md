---
layout: page
permalink: /narzedzia/profil-danych/
title: Profil jakości danych z pliku CSV
description: "Darmowe narzędzie online: wgraj plik CSV i sprawdź kompletność, unikalność i ważność danych z semaforem. Plik nie opuszcza Twojej przeglądarki."
nav: false
---

Wgraj plik CSV i zobacz w minutę, jak wygląda jakość danych w środku: ile wartości brakuje (także tych ukrytych pod `n/d`, `-` i `brak`), czy rekordy się nie powtarzają i czy numery NIP, e-maile i telefony mają poprawny format. Wynik dostajesz z semaforem w tych samych progach, co w [arkuszu Scorecard](/scorecard/): zielony od 95%, żółty od 85%, czerwony poniżej.

**Plik nie opuszcza Twojej przeglądarki.** Narzędzie liczy wszystko lokalnie, nie wysyła niczego na serwer, a przeglądarka dodatkowo blokuje jego połączenia sieciowe. Poniżej opisałem, jak możesz to sprawdzić samodzielnie.

<p class="profiler-actions"><a class="profiler-btn" href="{{ '/assets/tools/dq-profiler/' | relative_url }}">Otwórz narzędzie</a></p>

## Co robi

- **Kompletność:** liczy wypełnione pola wymagane i rekordy, w których wypełnione jest wszystko. Obsługuje reguły warunkowe, np. „NIP jest wymagany tylko wtedy, gdy typ klienta to firma".
- **Unikalność:** wyszukuje duplikaty po wskazanym kluczu albo identyczne wiersze.
- **Ważność:** sprawdza format e-maila, NIP (z sumą kontrolną), kod pocztowy, telefon, daty z przyszłości i zakresy liczbowe.
- **Raport:** wynik na wymiar i łączny, lista kolumn wymagających uwagi, eksport do HTML i JSON.

Narzędzie samo podpowiada reguły z nazw kolumn i z zawartości, a Ty możesz je zmienić. Szczegóły w [kodzie źródłowym](https://github.com/Szymok/dq-profiler) (licencja MIT).

## Jak sprawdzić, że dane nie wychodzą z przeglądarki

1. Otwórz narzędzie i naciśnij `F12` (narzędzia deweloperskie), zakładka **Sieć** (Network).
2. Wyczyść listę żądań i wybierz plik. Zbuduj raport i pobierz go.
3. Lista pozostaje pusta: po załadowaniu strony narzędzie nie wykonuje żadnych żądań.

Za tym stoją dwa mechanizmy. Plik jest czytany w przeglądarce przez standardowe API wyboru plików. Strona narzędzia ma politykę bezpieczeństwa treści (CSP) z dyrektywą `connect-src 'none'`, więc przeglądarka sama odrzuca każdą próbę połączenia, także z tej samej domeny. Zachowanie jest sprawdzane testami automatycznymi w przeglądarce, razem z odpornością na złośliwe nazwy kolumn.

Narzędzie działa na osobnej stronie, bez analityki i bez nagrywania sesji. Ta strona opisowa podlega ogólnym zasadom analityki serwisu, szczegóły w [polityce prywatności](/privacy-policy/).

## Czego narzędzie nie mierzy

To celowo mały zakres, żeby wynik był uczciwy:

- **Trzy z sześciu wymiarów jakości danych.** Nie ocenia dokładności (czy dane zgadzają się z rzeczywistością), spójności między systemami ani aktualności.
- **Poprawny format nie znaczy prawdziwa wartość.** NIP z dobrą sumą kontrolną może należeć do nieistniejącej firmy, a poprawnie wyglądający e-mail do nieistniejącej skrzynki.
- **Polskie formaty.** NIP, telefon i kod pocztowy są sprawdzane według polskich reguł.
- **Limit pliku: 25 MB** (UTF-8 lub Windows-1250, separator wykrywany automatycznie). Pamięć zużywana przez przeglądarkę jest wielokrotnie większa niż rozmiar pliku, stąd limit.
- Wynik łączny to prosta średnia ze zmierzonych wymiarów, a nie ocena całej organizacji.

Decyzję, które pola są wymagane i jaki próg jest akceptowalny, podejmuje właściciel danych, nie narzędzie. Bez niego wynik jest tylko liczbą.

## Plik do wypróbowania

Nie masz pod ręką pliku? Pobierz [klienci-przyklad.csv]({{ '/assets/files/klienci-przyklad.csv' | relative_url }}) (12 wymyślonych rekordów, bez prawdziwych danych) i wgraj do narzędzia. Numery NIP w pliku są wymyślone i celowo nie przechodzą sumy kontrolnej, więc reguła NIP pokaże błędy.

## Co dalej

- Wpisz wyniki do [arkusza Scorecard](/scorecard/) i porównaj z pozostałymi wymiarami. Wymiary raportu odpowiadają wymiarom arkusza: kompletność to „Kompletność", unikalność to „Unikalność", a ważność to „Zgodność formatu". Arkusz potrzebuje liczby rekordów, a raport podaje je w opisach wymiarów (np. „niepoprawne wartości: 4 z 33 sprawdzonych").
- Sprawdź w [teście dojrzałości Data Quality](/dojrzalosc-dq/) (12 pytań, 5 minut), czy w firmie ktoś odpowiada za takie pomiary.
- Jeśli potrzebujesz pełnego pomiaru w sześciu wymiarach z planem naprawy, zobacz [audyt jakości danych](/audyt-data-quality/).

<style>
  .profiler-actions { margin: 1.25rem 0; }
  .profiler-btn { display: inline-block; padding: 0.6rem 1.2rem; border: 2px solid var(--global-theme-color, #4f46e5); border-radius: 6px; background: var(--global-theme-color, #4f46e5); color: #fff; font-weight: 600; text-decoration: none; }
  .profiler-btn:hover, .profiler-btn:focus-visible { filter: brightness(1.12); color: #fff; text-decoration: none; }
  html[data-theme="dark"] .profiler-btn, html[data-theme="dark"] .profiler-btn:hover { color: #1c1c1d; }
</style>
