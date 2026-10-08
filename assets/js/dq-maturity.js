/* Test dojrzałości Data Quality: 12 pytań, 6 obszarów, wynik liczony w przeglądarce. */
(function (root) {
  "use strict";

  var AREAS = [
    {
      id: "sp",
      name: "Strategia i sponsoring",
      advice: [
        "Znajdź sponsora biznesowego i policz jeden konkretny koszt złych danych (np. duplikaty klientów, zwroty, korekty faktur).",
        "Data Quality traktowane jako projekt IT zwykle wygasa po pierwszym kwartale. Powiąż je z celem biznesowym.",
      ],
    },
    {
      id: "ro",
      name: "Role i odpowiedzialność",
      advice: [
        "Wyznacz właściciela (data owner) dla 3–5 najważniejszych zbiorów i jednego stewarda, który codziennie dba o jakość.",
        "Bez właściciela nikt nie naprawi błędu: spisz, kto odpowiada za jaki zbiór i kto go zastępuje.",
      ],
    },
    {
      id: "re",
      name: "Reguły i definicje",
      advice: [
        "Zacznij od 10 krytycznych reguł, a nie od 500. Dla każdej spisz wymiar, próg akceptacji, właściciela i częstotliwość pomiaru.",
        "Progi ustala biznes, nie IT. Dla danych krytycznych (np. NIP do faktur) próg jest wyższy niż dla pomocniczych.",
      ],
    },
    {
      id: "pm",
      name: "Pomiar",
      advice: [
        "Zrób pierwszy pomiar jednego zbioru w sześciu wymiarach i pokaż go jako semafor (zielony ≥ 95%, żółty 85–95%, czerwony < 85%).",
        "Zapisuj wyniki w czasie. Jedna liczba bez historii nie pokazuje, czy jest lepiej, czy gorzej.",
      ],
    },
    {
      id: "mo",
      name: "Monitoring i automatyzacja",
      advice: [
        "Przenieś najważniejsze reguły do potoków danych (ETL/ELT) i ustaw alerty dla właścicieli, zanim problem trafi do raportów.",
        "Jednorazowy audyt szybko się dezaktualizuje. Jakość danych to proces ciągły.",
      ],
    },
    {
      id: "na",
      name: "Naprawa i proces",
      advice: [
        "Ustal prosty obieg: zgłoszenie, właściciel, termin, analiza przyczyny źródłowej, trwała poprawka.",
        "Poprawianie raportu zamiast źródła tylko ukrywa problem i wraca przy następnym ładowaniu danych.",
      ],
    },
  ];

  // options[i] odpowiada punktom i (0–3)
  var QUESTIONS = [
    { area: "sp", text: "Kto w firmie odpowiada za jakość danych na poziomie zarządu?", options: [
      "Nikt, temat nie jest zgłaszany",
      "Temat pojawia się przy awariach lub skargach",
      "Jest sponsor biznesowy, ale bez stałego budżetu",
      "Jest sponsor, budżet i cele jakości danych w planach rocznych"] },
    { area: "sp", text: "Czy znacie koszt złej jakości danych w swojej firmie?", options: [
      "Nie, nigdy tego nie liczyliśmy",
      "Mamy pojedyncze, anegdotyczne przykłady",
      "Oszacowaliśmy koszt dla wybranych procesów",
      "Koszt jest mierzony i regularnie raportowany"] },
    { area: "ro", text: "Czy każdy kluczowy zbiór danych ma właściciela (data owner)?", options: [
      "Nie",
      "Nieformalnie, „wiadomo, kto to jest”",
      "Dla większości kluczowych zbiorów, spisane",
      "Dla wszystkich, z zakresem odpowiedzialności i zastępstwem"] },
    { area: "ro", text: "Kto naprawia błędy w danych?", options: [
      "Ten, kto je zauważy, najczęściej analityk",
      "IT, na zgłoszenie",
      "Data steward w wybranych obszarach",
      "Wyznaczeni data stewardzi ze ścieżką eskalacji i terminami"] },
    { area: "re", text: "Jak zdefiniowane są reguły jakości (np. „poprawny NIP”)?", options: [
      "Nie są spisane",
      "Są w głowach pojedynczych osób lub w rozproszonych dokumentach",
      "Mamy listę reguł z progami dla części danych",
      "Mamy katalog reguł z progami, właścicielami i przypisanym wymiarem jakości"] },
    { area: "re", text: "Czy macie progi akceptacji jakości uzgodnione z biznesem?", options: [
      "Nie",
      "Ogólnie zakładamy, że dane mają być „dobre”",
      "Progi mamy dla krytycznych danych",
      "Progi dla wszystkich reguł, zatwierdzone przez właścicieli danych"] },
    { area: "pm", text: "Jak mierzycie jakość danych?", options: [
      "Nie mierzymy",
      "Jednorazowe analizy lub sprawdzanie ad hoc",
      "Okresowe profilowanie wybranych zbiorów",
      "Regularny pomiar w wielu wymiarach z historią wyników"] },
    { area: "pm", text: "Czy macie zbiorczy widok jakości (scorecard) dla biznesu?", options: [
      "Nie",
      "Mamy raporty techniczne tylko dla IT",
      "Scorecard dla części danych, aktualizowany ręcznie",
      "Scorecard dla kluczowych danych, aktualizowany automatycznie"] },
    { area: "mo", text: "Kiedy dowiadujecie się o problemie z jakością danych?", options: [
      "Gdy użytkownik lub klient zgłosi błąd",
      "Podczas przygotowywania raportów",
      "Przy okresowych kontrolach",
      "Z automatycznego alertu, zanim problem trafi do raportów"] },
    { area: "mo", text: "Jak wyglądają kontrole jakości przy ładowaniu danych (ETL/ELT)?", options: [
      "Nie ma kontroli",
      "Pojedyncze, ręczne sprawdzenia",
      "Część potoków ma testy lub walidacje",
      "Testy jakości są standardem i blokują wadliwe ładowania"] },
    { area: "na", text: "Co dzieje się po wykryciu błędu w danych?", options: [
      "Poprawiamy go w raporcie lub arkuszu",
      "Poprawiamy w źródle, bez analizy przyczyny",
      "Tworzymy zgłoszenie z właścicielem i terminem",
      "Analizujemy przyczynę źródłową i trwale poprawiamy proces"] },
    { area: "na", text: "Czy jakość danych jest częścią codziennych procesów (wdrażanie pracowników, zmiany w systemach)?", options: [
      "Nie",
      "Tylko przy dużych projektach",
      "Uwzględniamy ją w wybranych procesach",
      "Jest wbudowana w procesy, szkolenia i zmiany systemów"] },
  ];

  var LEVELS = [
    { max: 25, name: "Poziom 1: Ad hoc", text: "Jakość danych nie jest zarządzana. Problemy wychodzą przy raportach i skargach klientów." },
    { max: 50, name: "Poziom 2: Reaktywny", text: "Reagujecie na problemy, ale im nie zapobiegacie. Brakuje właścicieli, reguł i regularnego pomiaru." },
    { max: 75, name: "Poziom 3: Zdefiniowany", text: "Macie role i reguły, a pomiar bywa nieregularny. Czas na automatyzację i monitoring." },
    { max: 100, name: "Poziom 4: Zarządzany", text: "Jakość jest mierzona i monitorowana. Zostaje optymalizacja i rozszerzanie zakresu." },
  ];

  var MAX_PER_QUESTION = 3;

  function levelFor(percent) {
    for (var i = 0; i < LEVELS.length; i++) {
      if (percent <= LEVELS[i].max) return { index: i + 1, name: LEVELS[i].name, text: LEVELS[i].text };
    }
    var last = LEVELS[LEVELS.length - 1];
    return { index: LEVELS.length, name: last.name, text: last.text };
  }

  function barClass(percent) {
    if (percent < 50) return "dq-low";
    if (percent < 75) return "dq-mid";
    return "dq-high";
  }

  // answers: tablica 12 liczb 0–3 (lub null dla braku odpowiedzi)
  function missingQuestions(answers) {
    var missing = [];
    for (var i = 0; i < QUESTIONS.length; i++) {
      var a = answers[i];
      if (a === null || a === undefined || a < 0 || a > MAX_PER_QUESTION) missing.push(i);
    }
    return missing;
  }

  function computeResult(answers) {
    var total = 0;
    var perArea = {};
    AREAS.forEach(function (a) { perArea[a.id] = { id: a.id, name: a.name, score: 0, max: 0, advice: a.advice }; });
    QUESTIONS.forEach(function (q, i) {
      var v = answers[i];
      perArea[q.area].score += v;
      perArea[q.area].max += MAX_PER_QUESTION;
      total += v;
    });
    var max = QUESTIONS.length * MAX_PER_QUESTION;
    var percent = Math.round((total / max) * 100);
    var areas = AREAS.map(function (a, order) {
      var p = perArea[a.id];
      return { id: p.id, name: p.name, score: p.score, max: p.max, percent: Math.round((p.score / p.max) * 100), advice: p.advice, order: order };
    });
    var weakest = areas.slice().sort(function (x, y) {
      return x.percent - y.percent || x.order - y.order;
    }).slice(0, 3);
    return { total: total, max: max, percent: percent, level: levelFor(percent), areas: areas, weakest: weakest };
  }

  function summaryText(result) {
    var lines = [
      "Test dojrzałości Data Quality: " + result.percent + "% (" + result.total + "/" + result.max + "), " + result.level.name,
    ];
    result.areas.forEach(function (a) { lines.push("- " + a.name + ": " + a.percent + "%"); });
    lines.push("https://skszymon.eu/dojrzalosc-dq/");
    return lines.join("\n");
  }

  // ---- UI -------------------------------------------------------------
  function el(tag, props, children) {
    var node = document.createElement(tag);
    if (props) Object.keys(props).forEach(function (k) {
      if (k === "className") node.className = props[k];
      else if (k === "text") node.textContent = props[k];
      else node.setAttribute(k, props[k]);
    });
    (children || []).forEach(function (c) { node.appendChild(c); });
    return node;
  }

  function link(href, text) { return el("a", { href: href, text: text }); }

  function render(container) {
    var answers = QUESTIONS.map(function () { return null; });
    container.textContent = "";

    var form = el("form", { className: "dq-form", novalidate: "novalidate" });
    var status = el("p", { className: "dq-status", role: "status", "aria-live": "polite" });
    var resultBox = el("div", { className: "dq-result", tabindex: "-1" });
    resultBox.hidden = true;

    var currentArea = null;
    QUESTIONS.forEach(function (q, i) {
      if (q.area !== currentArea) {
        currentArea = q.area;
        var areaName = AREAS.filter(function (a) { return a.id === q.area; })[0].name;
        form.appendChild(el("h2", { className: "dq-area", text: areaName }));
      }
      var fs = el("fieldset", { className: "dq-question", id: "dq-q" + i });
      fs.appendChild(el("legend", { text: (i + 1) + ". " + q.text }));
      q.options.forEach(function (label, score) {
        var id = "dq-q" + i + "-" + score;
        var input = el("input", { type: "radio", name: "dq-q" + i, id: id, value: String(score) });
        input.addEventListener("change", function () {
          answers[i] = score;
          fs.classList.remove("dq-missing");
          updateProgress();
        });
        fs.appendChild(el("div", { className: "dq-option" }, [input, el("label", { for: id, text: label })]));
      });
      form.appendChild(fs);
    });

    function answered() { return answers.filter(function (a) { return a !== null; }).length; }
    function updateProgress() {
      status.textContent = "Odpowiedziano na " + answered() + " z " + QUESTIONS.length + " pytań.";
    }

    var submit = el("button", { type: "submit", className: "dq-btn", text: "Pokaż wynik" });
    form.appendChild(el("div", { className: "dq-actions" }, [submit]));
    form.appendChild(status);
    updateProgress();

    form.addEventListener("submit", function (ev) {
      ev.preventDefault();
      var missing = missingQuestions(answers);
      QUESTIONS.forEach(function (_, i) {
        document.getElementById("dq-q" + i).classList.toggle("dq-missing", missing.indexOf(i) !== -1);
      });
      if (missing.length) {
        status.textContent = "Brakuje odpowiedzi w pytaniach: " + missing.map(function (m) { return m + 1; }).join(", ") + ".";
        var first = document.getElementById("dq-q" + missing[0]);
        first.scrollIntoView({ block: "center" });
        var firstInput = first.querySelector("input");
        if (firstInput) firstInput.focus();
        return;
      }
      showResult(computeResult(answers));
    });

    function showResult(result) {
      resultBox.textContent = "";
      resultBox.appendChild(el("h2", { text: "Twój wynik" }));
      resultBox.appendChild(el("p", { className: "dq-score" }, [
        el("strong", { text: result.percent + "%" }),
        document.createTextNode(" (" + result.total + " z " + result.max + " pkt) · "),
        el("strong", { text: result.level.name }),
      ]));
      resultBox.appendChild(el("p", { text: result.level.text }));

      var list = el("ul", { className: "dq-bars", "aria-label": "Wynik w obszarach" });
      result.areas.forEach(function (a) {
        var track = el("div", { className: "dq-track", "aria-hidden": "true" }, [
          el("div", { className: "dq-fill " + barClass(a.percent), style: "width:" + a.percent + "%" }),
        ]);
        list.appendChild(el("li", {}, [
          el("span", { className: "dq-bar-label", text: a.name }),
          track,
          el("span", { className: "dq-bar-value", text: a.percent + "%" }),
        ]));
      });
      resultBox.appendChild(list);

      resultBox.appendChild(el("h3", { text: "Od czego zacząć" }));
      result.weakest.forEach(function (a) {
        var block = el("div", { className: "dq-advice" }, [el("strong", { text: a.name + " (" + a.percent + "%)" })]);
        a.advice.forEach(function (t) { block.appendChild(el("p", { text: t })); });
        resultBox.appendChild(block);
      });

      var next = el("p", {}, [
        document.createTextNode("Następny krok: pobierz "),
        link("/scorecard/", "arkusz Data Quality Scorecard"),
        document.createTextNode(" i zmierz jeden zbiór, albo zobacz "),
        link("/audyt-data-quality/", "audyt Data Quality"),
        document.createTextNode(". Wymiary jakości opisuję w artykule "),
        link("/blog/2026/data-quality-dimensions/", "Wymiary jakości danych"),
        document.createTextNode("."),
      ]);
      resultBox.appendChild(next);

      var copy = el("button", { type: "button", className: "dq-btn dq-btn-secondary", text: "Skopiuj wynik" });
      copy.addEventListener("click", function () {
        var text = summaryText(result);
        var done = function () { copy.textContent = "Skopiowano"; };
        if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(text).then(done, function () {});
        else done();
      });
      var again = el("button", { type: "button", className: "dq-btn dq-btn-secondary", text: "Zacznij od nowa" });
      again.addEventListener("click", function () { render(container); container.scrollIntoView({ block: "start" }); });
      resultBox.appendChild(el("div", { className: "dq-actions" }, [copy, again]));

      resultBox.hidden = false;
      resultBox.scrollIntoView({ block: "start" });
      resultBox.focus();
    }

    container.appendChild(form);
    container.appendChild(resultBox);
  }

  var api = {
    AREAS: AREAS, QUESTIONS: QUESTIONS, LEVELS: LEVELS,
    computeResult: computeResult, levelFor: levelFor, missingQuestions: missingQuestions, summaryText: summaryText,
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = api;
  } else {
    root.DQMaturity = api;
    document.addEventListener("DOMContentLoaded", function () {
      var container = document.getElementById("dq-quiz");
      if (container) render(container);
    });
  }
})(typeof window !== "undefined" ? window : this);
