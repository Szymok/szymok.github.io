// Shared helpers for the site's browser tests (Playwright).

async function applyNetworkStubs(page) {
  // Keep tests deterministic and offline-friendly: third-party analytics/badges are never needed to judge the layout.
  const blockedDomains = ["google-analytics.com", "plausible.io", "badge.dimensions.ai", "giscus.app"];
  await page.route("**/*", (route) => {
    try {
      const hostname = new URL(route.request().url()).hostname.toLowerCase();
      if (blockedDomains.some((domain) => hostname === domain || hostname.endsWith(`.${domain}`))) {
        route.abort();
        return;
      }
    } catch {
      // fall through to continue
    }
    route.continue();
  });
}

async function preparePage(page, themeSetting = "light") {
  await page.addInitScript((setting) => {
    window.localStorage.setItem("theme", setting);
  }, themeSetting);
  await applyNetworkStubs(page);
}

async function stabilizeVisuals(page) {
  await page.evaluate(() => {
    const styleId = "__site_test_stabilize";
    if (document.getElementById(styleId)) {
      return;
    }
    const style = document.createElement("style");
    style.id = styleId;
    style.textContent = `
      *, *::before, *::after {
        animation-duration: 0ms !important;
        animation-delay: 0ms !important;
        caret-color: transparent !important;
      }
      iframe.giscus-frame,
      #giscus_thread,
      .cc-window {
        visibility: hidden !important;
      }
    `;
    document.head.appendChild(style);
  });
}

module.exports = {
  preparePage,
  stabilizeVisuals,
};
