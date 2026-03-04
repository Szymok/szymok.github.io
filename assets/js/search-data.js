// get the ninja-keys element
const ninja = document.querySelector('ninja-keys');

// add the home and posts menu items
ninja.data = [{
    id: "nav-about",
    title: "about",
    section: "Navigation",
    handler: () => {
      window.location.href = "/";
    },
  },{id: "nav-blog",
          title: "blog",
          description: "",
          section: "Navigation",
          handler: () => {
            window.location.href = "/blog/";
          },
        },{id: "nav-cv",
          title: "cv",
          description: "Moje CV — doświadczenie zawodowe, edukacja i umiejętności.",
          section: "Navigation",
          handler: () => {
            window.location.href = "/cv/";
          },
        },{id: "dropdown-ogród-wiedzy",
              title: "ogród wiedzy",
              description: "",
              section: "Dropdown",
              handler: () => {
                window.location.href = "http://quartz.skszymon.eu";
              },
            },{id: "post-ai-w-data-governance-szanse-wyzwania-i-praktyczne-zastosowania",
        
          title: "AI w Data Governance: szanse, wyzwania i praktyczne zastosowania",
        
        description: "Jak AI zmienia zarządzanie danymi? Od automatycznej klasyfikacji PII po frontier data governance — analiza na podstawie pracy z arXiv.",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2025/ai-models-dg/";
          
        },
      },{id: "post-ataccama-one-dlaczego-wybrałem-tę-platformę-do-data-governance",
        
          title: "Ataccama ONE — dlaczego wybrałem tę platformę do Data Governance",
        
        description: "Przegląd Ataccama ONE z perspektywy codziennego użytkownika — co potrafi, jak wygląda w praktyce i dla kogo się nadaje.",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2025/ataccama/";
          
        },
      },{id: "post-informatica-jako-narzędzie-data-governance-przegląd-dla-praktyków",
        
          title: "Informatica jako narzędzie Data Governance: przegląd dla praktyków",
        
        description: "Przegląd platformy Informatica Data Governance — Axon, EDC, CLAIRE GPT. Co potrafi, do czego się nadaje i jak wypada na tle konkurencji.",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2025/informatica/";
          
        },
      },{id: "post-standardy-danych-czym-są-i-dlaczego-bez-nich-nie-zbudujesz-programu-dg",
        
          title: "Standardy danych: czym są i dlaczego bez nich nie zbudujesz programu DG?",
        
        description: "Czym są standardy danych, jak działają w praktyce i dlaczego interoperacyjność jest kluczowa — analiza na podstawie inicjatywy TransparenCEE.",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2024/dg-standars/";
          
        },
      },{id: "post-które-normy-iso-stosować-w-data-governance-praktyczny-przegląd",
        
          title: "Które normy ISO stosować w Data Governance? Praktyczny przegląd",
        
        description: "Przegląd standardów ISO przydatnych w programie Data Governance — od jakości danych (ISO 8000) po bezpieczeństwo informacji (ISO 27001).",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2024/dg-iso-standards/";
          
        },
      },{id: "post-wstęp-do-data-governance",
        
          title: "Wstęp do Data Governance",
        
        description: "Od czego zacząć przygodę z zarządzaniem danymi? Kluczowe elementy, role i wyzwania — z perspektywy praktyka.",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2024/data-governance-start/";
          
        },
      },{id: "post-wstęp-do-promptingu",
        
          title: "Wstęp do Promptingu",
        
        description: "Praktyczny przewodnik po promptingu — zasady, iteracyjny rozwój, podsumowywanie, analiza sentymentu i transformacja tekstu z OpenAI API.",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2023/guide-prompting/";
          
        },
      },{id: "post-historia-wizualizacji-danych",
        
          title: "Historia wizualizacji danych",
        
        description: "Od malowideł naskalnych po Tableau — historia wizualizacji danych przez pryzmat Playfaira, Nightingale, Snowa, Minarda, Tukeya i Tufta.",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2023/history-visualization/";
          
        },
      },{id: "books-the-godfather",
          title: 'The Godfather',
          description: "",
          section: "Books",handler: () => {
              window.location.href = "/books/the_godfather/";
            },},{id: "news-pierwszy-artykuł",
          title: 'Pierwszy artykuł',
          description: "",
          section: "News",},{id: "news-opublikowałem-nowy-artykuł-wymiary-jakości-danych-praktyczny-przewodnik-po-data-quality-6-wymiarów-metryki-narzędzia-i-najczęstsze-błędy-wdrożeniowe",
          title: 'Opublikowałem nowy artykuł: Wymiary jakości danych — praktyczny przewodnik po Data Quality. 6...',
          description: "",
          section: "News",},{
        id: 'social-email',
        title: 'email',
        section: 'Socials',
        handler: () => {
          window.open("mailto:%68%65%6C%6C%6F@%73%6B%73%7A%79%6D%6F%6E.%65%75", "_blank");
        },
      },{
        id: 'social-github',
        title: 'GitHub',
        section: 'Socials',
        handler: () => {
          window.open("https://github.com/Szymok", "_blank");
        },
      },{
        id: 'social-linkedin',
        title: 'LinkedIn',
        section: 'Socials',
        handler: () => {
          window.open("https://www.linkedin.com/in/skszymon", "_blank");
        },
      },{
        id: 'social-x',
        title: 'X',
        section: 'Socials',
        handler: () => {
          window.open("https://twitter.com/SkSzymon", "_blank");
        },
      },{
        id: 'social-rss',
        title: 'RSS Feed',
        section: 'Socials',
        handler: () => {
          window.open("/feed.xml", "_blank");
        },
      },{
      id: 'light-theme',
      title: 'Change theme to light',
      description: 'Change the theme of the site to Light',
      section: 'Theme',
      handler: () => {
        setThemeSetting("light");
      },
    },
    {
      id: 'dark-theme',
      title: 'Change theme to dark',
      description: 'Change the theme of the site to Dark',
      section: 'Theme',
      handler: () => {
        setThemeSetting("dark");
      },
    },
    {
      id: 'system-theme',
      title: 'Use system default theme',
      description: 'Change the theme of the site to System Default',
      section: 'Theme',
      handler: () => {
        setThemeSetting("system");
      },
    },];
