#!/usr/bin/env bash
# Guards the DQ Profiler promise on the built site: the app is a separate document with a strict CSP,
# carries no analytics or session recording, is the exact build recorded in VERSION, and stays out of the sitemap.
set -euo pipefail

tmp_dir="$(mktemp -d)"
tmp_site="${tmp_dir}/site"

cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

fail() {
  printf 'profiler integration check failed: %b\n' "$*" >&2
  exit 1
}

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

bundle exec jekyll build -d "${tmp_site}" >/dev/null

app_dir="${tmp_site}/assets/tools/dq-profiler"
app="${app_dir}/index.html"
landing="${tmp_site}/narzedzia/profil-danych/index.html"
sitemap="${tmp_site}/sitemap.xml"
policy="${tmp_site}/privacy-policy/index.html"

# --- the app: strict CSP, no analytics, no layout, own scripts only ---
[ -f "${app}" ] || fail "missing ${app}"
grep -Eq "connect-src (&#39;|')none(&#39;|')" "${app}" || fail "app has no connect-src 'none' policy"
grep -Eq "default-src (&#39;|')none(&#39;|')" "${app}" || fail "app has no default-src 'none' policy"
if grep -Eiq 'umami|recorder\.js|script\.js|googletagmanager|gtag\(|cookieconsent' "${app}"; then
  fail "app page contains analytics, session recording or cookie-banner code"
fi
if grep -Eiq '<script[^>]*src="https?:' "${app}"; then
  fail "app page loads a script from another origin"
fi
grep -Eq 'name="robots" content="noindex"' "${app}" || fail "app page is not marked noindex"

# --- no file in the app directory may contain tracking code either ---
if grep -rEil 'umami|recorder\.js|googletagmanager' "${app_dir}" | grep -v '/VERSION$' | grep -q .; then
  fail "a file in the app directory references analytics"
fi

# --- the build in the site is exactly the release recorded in VERSION ---
version="${app_dir}/VERSION"
[ -f "${version}" ] || fail "missing ${version}"
grep -q '^working-tree: clean$' "${version}" || fail "VERSION records a build from an unclean working tree"
grep -Eq '^tag: v[0-9]+\.[0-9]+\.[0-9]+$' "${version}" || fail "VERSION does not record a release tag"
checked=0
mismatches=""
while read -r expected path; do
  [ -n "${path}" ] || continue
  [ -f "${app_dir}/${path}" ] || fail "VERSION lists ${path} but it is missing from the site"
  actual="$(sha256_of "${app_dir}/${path}")"
  if [ "${actual}" != "${expected}" ]; then
    # Collect every difference (not only the first) with sizes, to show what the build pipeline altered.
    mismatches="${mismatches}\n  ${path}: release ${expected:0:12}, built site ${actual:0:12} ($(wc -c <"${app_dir}/${path}" | tr -d ' ') bytes)"
  fi
  checked=$((checked + 1))
done < <(sed -n '/^sha256:$/,$p' "${version}" | tail -n +2)
[ "${checked}" -gt 0 ] || fail "VERSION lists no files"
[ -z "${mismatches}" ] || fail "the built site differs from the release:${mismatches}"

# --- the descriptive page: exists, links to the app, no iframe ---
[ -f "${landing}" ] || fail "missing ${landing}"
grep -q 'href="/assets/tools/dq-profiler/"' "${landing}" || fail "landing page does not link to the app"
if grep -qi '<iframe' "${landing}"; then
  fail "landing page embeds the app in an iframe; the app must stay a separate document"
fi
if grep -q 'data-umami-event' "${landing}"; then
  fail "landing page carries tool-specific analytics events"
fi

# --- the tool is reachable from the pages that are meant to lead to it ---
# The navbar links to the tool on every page, so a bare "contains the link" check would still pass after the page's
# own link was removed. Count occurrences and require more than a page that only has the navbar entry.
count_links() {
  grep -o 'href="/narzedzia/profil-danych/"' "$1" | wc -l | tr -d ' '
}
baseline="$(count_links "${policy}")"
[ "${baseline}" -ge 1 ] || fail "the navbar no longer links to the tool"
for page in audyt-data-quality scorecard; do
  [ "$(count_links "${tmp_site}/${page}/index.html")" -gt "${baseline}" ] || fail "${page} page has no link of its own to the tool"
done

# --- sitemap: the landing page is listed, the app is not ---
grep -q 'narzedzia/profil-danych' "${sitemap}" || fail "landing page missing from the sitemap"
if grep -q 'tools/dq-profiler' "${sitemap}"; then
  fail "the app is listed in the sitemap"
fi

# --- the privacy policy describes the tool ---
grep -q 'DQ Profiler' "${policy}" || fail "privacy policy does not mention the DQ Profiler"

echo "profiler integration checks passed (${checked} files verified against VERSION)"
