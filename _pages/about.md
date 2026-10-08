---
layout: about
title: about
permalink: /
description: "Szymon Kowalewski, Data Governance Specialist. Audyt jakości danych dla firm, test dojrzałości Data Quality oraz blog o Data Governance, Data Quality, AI i self-hostingu."
subtitle: <a href='/blog/'>Data Governance · Data Quality · AI · Self-hosting</a>

profile:
  align: right
  image: prof_pic.jpg
  image_circular: true # crops the image to make it circular
  more_info: >
    <p>Data Governance Specialist</p>
    <p>BEST S.A. · Trójmiasto</p>

selected_papers: false # includes a list of papers marked as "selected={true}"
social: true # includes social icons at the bottom of the page

announcements:
  enabled: true # includes a list of news items
  scrollable: true # adds a vertical scroll bar if there are more than 3 news items
  limit: 5 # leave blank to include all the news in the `_news` folder

latest_posts:
  enabled: true
  scrollable: true # adds a vertical scroll bar if there are more than 3 new posts items
  limit: 3 # leave blank to include all the blog posts
---

<div class="home-hero">
  <p class="home-lead">Audyt jakości danych dla firm: wynik w sześciu wymiarach i plan na 90 dni.</p>
  <p>Mierzę, jak bardzo dane w Twojej firmie są zepsute, wskazuję, co naprawić najpierw, i zostawiam plan działania. Stała cena, bez kupowania licencji.</p>
  <p class="home-actions">
    <a class="home-btn" href="/audyt-data-quality/">Zobacz ofertę audytu</a>
    <a class="home-btn home-btn-ghost" href="/dojrzalosc-dq/">Zrób test dojrzałości (5 min)</a>
  </p>
</div>

## Zacznij tutaj

<div class="home-cards">
  <a class="home-card" href="/dojrzalosc-dq/"><strong>Test dojrzałości Data Quality</strong><span>12 pytań, 5 minut, wynik w 6 obszarach i trzy rzeczy na start.</span></a>
  <a class="home-card" href="/scorecard/"><strong>Arkusz Scorecard</strong><span>Zmierz pierwszy zbiór danych samodzielnie, w sześciu wymiarach.</span></a>
  <a class="home-card" href="/blog/2026/data-quality-dimensions/"><strong>Wymiary jakości danych</strong><span>Artykuł startowy: 6 wymiarów, metryki i najczęstsze błędy wdrożeń.</span></a>
</div>

## O mnie

Specjalizuję się w `zarządzaniu danymi` i `jakości danych`, pomagając organizacjom budować fundamenty pod wiarygodne analizy i decyzje biznesowe. Na co dzień pracuję z platformą `Ataccama` — wdrażam procesy Data Governance, Data Quality i Master Data Management.

Na tym blogu będę pisał głównie o **AI**, **Data Governance & Quality** oraz **self-hostingu**. Chcę dzielić się tu swoimi doświadczeniami, dokumentując drogowskazy w świecie danych, automatyzacji oraz hostowania własnych usług.

Dłuższe omówienia znajdziesz na [blogu](/blog/), a moje notatki robocze z Data Governance, Data Quality i AI zbieram w [ogrodzie wiedzy](/garden/). Dobry punkt startowy: [wymiary jakości danych](/blog/2026/data-quality-dimensions/).

Wcześniej pracowałem jako Data Consultant (Hogart/Pernod Ricard), Junior Data Engineer (No Fluff Jobs) oraz Data Scout (Statscore). Jestem absolwentem `Informatyki i Ekonometrii` na Uniwersytecie Gdańskim.

<style>
  .home-hero { margin: 0 0 1.5rem; padding: 1.25rem 1.5rem; border: 1px solid color-mix(in srgb, currentColor 18%, transparent); border-left: 6px solid var(--global-theme-color, #1d4b8f); border-radius: 8px; }
  .home-lead { margin: 0 0 0.5rem; font-size: 1.35rem; font-weight: 700; line-height: 1.25; }
  .home-actions { display: flex; flex-wrap: wrap; gap: 0.75rem; margin: 1rem 0 0; }
  .home-btn { display: inline-block; padding: 0.55rem 1.1rem; border: 2px solid var(--global-theme-color, #1d4b8f); border-radius: 6px; background: var(--global-theme-color, #1d4b8f); color: #fff; font-weight: 600; text-decoration: none; }
  .home-btn:hover, .home-btn:focus-visible { filter: brightness(1.12); color: #fff; text-decoration: none; }
  html[data-theme="dark"] .home-btn:not(.home-btn-ghost), html[data-theme="dark"] .home-btn:not(.home-btn-ghost):hover { color: #1c1c1d; }
  .home-btn-ghost { background: transparent; color: var(--global-theme-color, #1d4b8f); }
  .home-btn-ghost:hover, .home-btn-ghost:focus-visible { color: var(--global-theme-color, #1d4b8f); background: color-mix(in srgb, var(--global-theme-color, #1d4b8f) 10%, transparent); }
  .home-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(13rem, 1fr)); gap: 0.75rem; margin: 0.75rem 0 1.5rem; }
  .home-card { display: block; padding: 0.9rem 1rem; border: 1px solid color-mix(in srgb, currentColor 20%, transparent); border-radius: 8px; color: inherit; text-decoration: none; }
  .home-card:hover, .home-card:focus-visible { border-color: var(--global-theme-color, #1d4b8f); text-decoration: none; }
  .home-card strong { display: block; color: var(--global-theme-color, #1d4b8f); }
  .home-card span { display: block; margin-top: 0.25rem; font-size: 0.9rem; opacity: 0.85; }
</style>
