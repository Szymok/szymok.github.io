const { test, expect } = require("@playwright/test");
const { preparePage, stabilizeVisuals } = require("./helpers");

// The site's own pages. Tests describe what must hold for *this* site (layout, rendering, themes),
// not similarity to any upstream template.
const routes = [
  { path: "/", id: "home" },
  { path: "/blog/", id: "blog" },
  { path: "/blog/2026/reguly-jakosci-danych-sql/", id: "post: reguly jakosci danych" },
  { path: "/blog/2026/kompletnosc-danych-sql/", id: "post: kompletnosc danych" },
  { path: "/scorecard/", id: "scorecard" },
  { path: "/audyt-data-quality/", id: "audyt" },
  { path: "/dojrzalosc-dq/", id: "dojrzalosc" },
  { path: "/narzedzia/", id: "narzedzia" },
  { path: "/narzedzia/profil-danych/", id: "profil danych" },
  { path: "/privacy-policy/", id: "privacy" },
];

for (const theme of ["light", "dark"]) {
  for (const route of routes) {
    test(`renders cleanly: ${route.id} (${theme})`, async ({ page }) => {
      const failures = [];
      page.on("pageerror", (error) => failures.push(`pageerror: ${error.message}`));
      page.on("console", (message) => {
        // Blocked third-party hosts surface as "Failed to load resource"; those are expected here.
        if (message.type() === "error" && !/Failed to load resource|net::ERR/i.test(message.text())) {
          failures.push(`console: ${message.text()}`);
        }
      });

      await preparePage(page, theme);
      const response = await page.goto(route.path, { waitUntil: "networkidle" });
      await stabilizeVisuals(page);

      expect(response && response.status()).toBe(200);
      await expect(page.locator("h1").first()).toBeVisible();

      // No horizontal page scroll at any viewport: wide tables and code must scroll inside their own box.
      const overflow = await page.evaluate(() => ({
        scrollWidth: document.documentElement.scrollWidth,
        innerWidth: window.innerWidth,
      }));
      expect(overflow.scrollWidth, `page overflows horizontally (${overflow.scrollWidth} > ${overflow.innerWidth})`).toBeLessThanOrEqual(
        overflow.innerWidth + 1
      );

      // Images must actually decode (lazy images are forced to load first).
      await page.evaluate(() => document.querySelectorAll("img[loading='lazy']").forEach((img) => (img.loading = "eager")));
      await page.waitForTimeout(500);
      const brokenImages = await page.evaluate(() =>
        Array.from(document.images)
          .filter((img) => img.src && img.complete && img.naturalWidth === 0 && !img.src.startsWith("data:"))
          .map((img) => img.src)
      );
      expect(brokenImages).toEqual([]);

      expect(failures).toEqual([]);
    });
  }
}

test("dark theme actually switches colors", async ({ page }) => {
  await preparePage(page, "light");
  await page.goto("/", { waitUntil: "networkidle" });
  const light = await page.evaluate(() => window.getComputedStyle(document.body).backgroundColor);

  const dark = await (async () => {
    const darkPage = await page.context().newPage();
    await preparePage(darkPage, "dark");
    await darkPage.goto("/", { waitUntil: "networkidle" });
    const color = await darkPage.evaluate(() => window.getComputedStyle(document.body).backgroundColor);
    await darkPage.close();
    return color;
  })();

  expect(dark).not.toBe(light);
});

test.describe("post: reguly jakosci danych", () => {
  const post = "/blog/2026/reguly-jakosci-danych-sql/";

  test("SQL download resolves and every internal link works", async ({ page, request }) => {
    await preparePage(page, "light");
    await page.goto(post, { waitUntil: "networkidle" });

    const hrefs = await page.evaluate(() =>
      Array.from(document.querySelectorAll("article a[href], .post a[href]"))
        .map((a) => a.getAttribute("href"))
        .filter((href) => href && href.startsWith("/") && !href.startsWith("//"))
    );
    expect(hrefs).toContain("/assets/files/reguly-jakosci-danych.sql");

    for (const href of [...new Set(hrefs.map((h) => h.split("#")[0]).filter(Boolean))]) {
      const response = await request.get(href);
      expect(response.status(), `${href} should resolve`).toBe(200);
    }
  });

  test("code blocks and tables stay inside the page", async ({ page }) => {
    await preparePage(page, "light");
    await page.goto(post, { waitUntil: "networkidle" });

    expect(await page.locator("pre").count()).toBeGreaterThanOrEqual(12);

    // A wide <pre>/<table> is fine only when it scrolls inside its own box and that box fits the viewport.
    const escaping = await page.evaluate(() => {
      const viewport = window.innerWidth;
      const scrollContainer = (el) => {
        for (let node = el; node && node !== document.body; node = node.parentElement) {
          if (getComputedStyle(node).overflowX !== "visible") {
            return node;
          }
        }
        return null;
      };
      return Array.from(document.querySelectorAll("pre, table"))
        .filter((el) => {
          const box = scrollContainer(el) || el;
          return box.getBoundingClientRect().right > viewport + 1;
        })
        .map((el) => `${el.tagName} (${Math.round(el.getBoundingClientRect().right)}px > ${viewport}px)`);
    });
    expect(escaping).toEqual([]);
  });

  test("toc lists the twelve rules sections on desktop", async ({ page }, testInfo) => {
    test.skip(testInfo.project.name === "mobile", "TOC sidebar is hidden on mobile viewport");

    await preparePage(page, "light");
    await page.goto(post, { waitUntil: "networkidle" });

    const tocLinks = page.locator("#toc-sidebar .toc-link");
    await expect.poll(async () => tocLinks.count()).toBeGreaterThan(5);
    await expect(page.locator("#toc-sidebar").getByText("Gdzie kończy się SQL")).toHaveCount(1);
  });
});
