#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
tmp_override="${tmp_dir}/comments-test-override.yml"
tmp_site="${tmp_dir}/site"

# This site does not ship the upstream demo posts, so the test brings its own: two throwaway posts that are
# removed again on exit.
giscus_post="_posts/2020-01-01-zz-comments-test-giscus.md"
disqus_post="_posts/2020-01-01-zz-comments-test-disqus.md"

cleanup() {
  rm -f "${giscus_post}" "${disqus_post}"
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

printf -- '---\nlayout: post\ntitle: comments test giscus\ndate: 2020-01-01\ngiscus_comments: true\n---\n\ntest\n' >"${giscus_post}"
printf -- '---\nlayout: post\ntitle: comments test disqus\ndate: 2020-01-01\ndisqus_comments: true\n---\n\ntest\n' >"${disqus_post}"

cat >"${tmp_override}" <<'YAML'
giscus:
  repo: alshedivat/al-folio
  repo_id: R_kgDOExample
  category: Comments
  category_id: DIC_kwDOExample
YAML

bundle exec jekyll build --config "_config.yml,${tmp_override}" -d "${tmp_site}" >/dev/null

giscus_page="${tmp_site}/blog/2020/zz-comments-test-giscus/index.html"
disqus_page="${tmp_site}/blog/2020/zz-comments-test-disqus/index.html"

grep -q 'https://giscus.app/client.js' "${giscus_page}"
if grep -q 'giscus comments misconfigured' "${giscus_page}"; then
  echo "unexpected giscus misconfiguration warning in ${giscus_page}" >&2
  exit 1
fi

grep -q 'id="disqus_thread"' "${disqus_page}"
grep -q '.disqus.com/embed.js' "${disqus_page}"

echo "comments integration checks passed"
