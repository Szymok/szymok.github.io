---
layout: page
title: Ataccama ONE
tool_tag: ataccama
vendor_url: https://www.ataccama.com/
description: "Wpisy o Ataccama ONE: jakość danych, katalog i glosariusz z perspektywy użytkownika, plus moje ułatwienia do pracy z platformą."
# Moje ułatwienia do tego narzędzia. Wpis: { title, url, description }. Sekcja pojawia się, gdy lista nie jest pusta.
helpers: []
---

[Ataccama ONE]({{ page.vendor_url }}) to platforma do zarządzania danymi (jakość, katalog, glosariusz, MDM). Poniżej zebrałem wszystkie wpisy na blogu o tym narzędziu.

{% assign tool_posts = site.posts | where_exp: "p", "p.tags contains page.tool_tag" %}

## Wpisy o {{ page.title }}

{% if tool_posts.size > 0 %}

<ul>
  {% for p in tool_posts %}
  <li><a href="{{ p.url | relative_url }}">{{ p.title }}</a> <span class="text-muted">({{ p.date | date: "%Y-%m-%d" }})</span></li>
  {% endfor %}
</ul>
{% else %}
Na razie brak wpisów.
{% endif %}

{% if page.helpers.size > 0 %}

## Moje ułatwienia

<ul>
  {% for h in page.helpers %}
  <li><a href="{{ h.url | relative_url }}">{{ h.title }}</a>: {{ h.description }}</li>
  {% endfor %}
</ul>
{% endif %}

[← wszystkie narzędzia]({{ '/narzedzia/' | relative_url }})
