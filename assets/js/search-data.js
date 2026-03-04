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
            },{id: "dropdown-bookshelf",
              title: "bookshelf",
              description: "",
              section: "Dropdown",
              handler: () => {
                window.location.href = "/books/";
              },
            },{id: "post-kierunek-zarządzania-danymi-w-pionierskich-modelach-sztucznej-inteligencji",
        
          title: "Kierunek zarządzania danymi w pionierskich modelach sztucznej inteligencji",
        
        description: "Zarządzanie danymi jako brakujący filar bezpieczeństwa i regulacji frontier AI",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2025/ai-models-dg/";
          
        },
      },{id: "post-ataccama-jako-narzędzie-data-governance",
        
          title: "Ataccama jako narzędzie Data Governance",
        
        description: "Zarzadzanie danymi w XXI wieku",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2025/ataccama/";
          
        },
      },{id: "post-informatica-jako-narzędzie-data-governance",
        
          title: "Informatica jako narzędzie Data Governance",
        
        description: "",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2025/informatica/";
          
        },
      },{id: "post-standardy-danych-czym-są-i-dlaczego-są-ważne-analiza",
        
          title: "Standardy danych. Czym są i dlaczego są ważne? Analiza",
        
        description: "Ale czym są te standardy danych? Dlaczego są ważne? Jakie są ich korzyści?",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2024/dg-standars/";
          
        },
      },{id: "post-które-normy-iso-są-stosowane-w-data-governance",
        
          title: "Które normy ISO są stosowane w Data Governance?",
        
        description: "Często stosowane standardy ISO w praktykach Data Governance.",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2024/dg-iso-standards/";
          
        },
      },{id: "post-wstęp-do-data-governance",
        
          title: "Wstęp do Data Governance",
        
        description: "Początek serii postów na temat Data Governance.",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2024/data-governance-start/";
          
        },
      },{id: "post-wstęp-do-promptingu",
        
          title: "Wstęp do Promptingu",
        
        description: "Jak, dlaczego i jakich używać taktyk pisania promptów",
        section: "Posts",
        handler: () => {
          
            window.location.href = "/blog/2023/guide-prompting/";
          
        },
      },{id: "post-historia-wizualizacji-danych",
        
          title: "Historia wizualizacji danych",
        
        description: "Artykuł, który skupia sie na historii wizualizacji danych",
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
          section: "News",},{
        id: 'social-email',
        title: 'email',
        section: 'Socials',
        handler: () => {
          window.open("mailto:%73%7A%79%6D%6F%6E%6B%6F%77%61%6C%30%31%39@%67%6D%61%69%6C.%63%6F%6D", "_blank");
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
