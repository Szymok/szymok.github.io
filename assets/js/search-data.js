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
        },{id: "nav-projects",
          title: "projects",
          description: "Projekty i linki do moich projektów. Aktualnie pracuję nad wdrożeniami modeli AI do różnych dziedzin życia.",
          section: "Navigation",
          handler: () => {
            window.location.href = "/projects/";
          },
        },{id: "nav-repositories",
          title: "repositories",
          description: "Moje projekty na GitHubie.",
          section: "Navigation",
          handler: () => {
            window.location.href = "/repositories/";
          },
        },{id: "nav-cv",
          title: "cv",
          description: "Strona z moim cv. Za pomocą przycisku PDF można pobrać plik z moim cv.",
          section: "Navigation",
          handler: () => {
            window.location.href = "/cv/";
          },
        },{id: "nav-teaching",
          title: "teaching",
          description: "Materiały z kursów i warsztatów",
          section: "Navigation",
          handler: () => {
            window.location.href = "/teaching/";
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
            },{id: "dropdown-publications",
              title: "publications",
              description: "",
              section: "Dropdown",
              handler: () => {
                window.location.href = "/publications/";
              },
            },{id: "dropdown-people",
              title: "people",
              description: "",
              section: "Dropdown",
              handler: () => {
                window.location.href = "/people/";
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
            },},{id: "news-a-long-announcement-with-details",
          title: 'A long announcement with details',
          description: "",
          section: "News",handler: () => {
              window.location.href = "/news/announcement_2/";
            },},{id: "news-sparkles-smile",
          title: ':sparkles: :smile:',
          description: "",
          section: "News",},{id: "news-pierwszy-artykuł",
          title: 'Pierwszy artykuł',
          description: "",
          section: "News",},{id: "projects-analiza-la-liga",
          title: 'Analiza La Liga',
          description: "Analityczna aplikacja z danymi dotyczacymi La Liga",
          section: "Projects",handler: () => {
              window.location.href = "/projects/1_project/";
            },},{id: "projects-skrapowanie-danych",
          title: 'Skrapowanie danych',
          description: "Projekt skrapowania danych z serwisow z ogloszeniami o prace",
          section: "Projects",handler: () => {
              window.location.href = "/projects/2_project/";
            },},{id: "projects-baika",
          title: 'bAIka',
          description: "projekt generowania bajek z wykorzystaniem sztucznej inteligencji",
          section: "Projects",handler: () => {
              window.location.href = "/projects/3_project/";
            },},{id: "projects-project-4",
          title: 'project 4',
          description: "another without an image",
          section: "Projects",handler: () => {
              window.location.href = "/projects/4_project/";
            },},{id: "projects-project-5",
          title: 'project 5',
          description: "a project with a background image",
          section: "Projects",handler: () => {
              window.location.href = "/projects/5_project/";
            },},{id: "projects-project-6",
          title: 'project 6',
          description: "a project with no image",
          section: "Projects",handler: () => {
              window.location.href = "/projects/6_project/";
            },},{id: "projects-project-7",
          title: 'project 7',
          description: "with background image",
          section: "Projects",handler: () => {
              window.location.href = "/projects/7_project/";
            },},{id: "projects-project-8",
          title: 'project 8',
          description: "an other project with a background image and giscus comments",
          section: "Projects",handler: () => {
              window.location.href = "/projects/8_project/";
            },},{id: "projects-project-9",
          title: 'project 9',
          description: "another project with an image 🎉",
          section: "Projects",handler: () => {
              window.location.href = "/projects/9_project/";
            },},{
        id: 'social-email',
        title: 'email',
        section: 'Socials',
        handler: () => {
          window.open("mailto:%73%7A%79%6D%6F%6E%6B%6F%77%61%6C%30%31%39@%67%6D%61%69%6C.%63%6F%6D", "_blank");
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
