---
layout: page
permalink: /narzedzia/
title: narzędzia
description: "Darmowe mini narzędzia do pracy z jakością danych (DQ) i zarządzaniem danymi (DG). Działają w przeglądarce, bez wysyłania danych na serwer."
nav: true
nav_order: 4
---

Małe, darmowe narzędzia do codziennej pracy z jakością danych (DQ) i zarządzaniem danymi (DG). Każde robi jedną rzecz i działa w przeglądarce. Kolejne będę dodawać tutaj.

## Platformy DQ/DG

Wybierz platformę, żeby zobaczyć wpisy z bloga o niej i moje ułatwienia do pracy z nią.

<ul class="tools-list">
  {% assign platforms = site.dq_tools | sort: "title" %}
  {% for t in platforms %}
  {% assign t_posts = site.posts | where_exp: "p", "p.tags contains t.tool_tag" %}
  <li class="tools-card">
    <h2><a href="{{ t.url | relative_url }}">{{ t.title }}</a></h2>
    <p>{{ t.description }}</p>
    <p class="tools-tags">wpisy: {{ t_posts.size }}{% if t.helpers.size > 0 %} · ułatwienia: {{ t.helpers.size }}{% endif %}</p>
  </li>
  {% endfor %}
</ul>

## Mini narzędzia

<ul class="tools-list">
  <li class="tools-card">
    <h2><a href="{{ '/narzedzia/profil-danych/' | relative_url }}">Profil danych CSV</a></h2>
    <p>Wgraj plik CSV i sprawdź kompletność, unikalność i ważność danych z semaforem. Plik nie opuszcza Twojej przeglądarki.</p>
    <p class="tools-tags">DQ · profilowanie · CSV</p>
  </li>
  <li class="tools-card">
    <h2><a href="{{ '/dojrzalosc-dq/' | relative_url }}">Test dojrzałości Data Quality</a></h2>
    <p>12 pytań, 5 minut. Sprawdź, czy w firmie ktoś odpowiada za pomiar i poprawę jakości danych.</p>
    <p class="tools-tags">DQ · DG · ocena</p>
  </li>
  <li class="tools-card">
    <h2><a href="{{ '/scorecard/' | relative_url }}">Data Quality Scorecard</a></h2>
    <p>Arkusz do zbierania wyników w wymiarach jakości danych, z progami semafora.</p>
    <p class="tools-tags">DQ · arkusz · Excel</p>
  </li>
</ul>

<style>
  .tools-list { list-style: none; padding: 0; margin: 1.5rem 0; display: grid; gap: 1rem; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); }
  .tools-card { padding: 1rem 1.25rem; border: 1px solid var(--global-divider-color, #ddd); border-radius: 8px; }
  .tools-card h2 { font-size: 1.15rem; margin: 0 0 0.5rem; }
  .tools-card p { margin: 0 0 0.5rem; }
  .tools-tags { font-size: 0.85rem; color: var(--global-text-color-light, #777); }
</style>
