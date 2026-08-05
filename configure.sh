#!/usr/bin/env bash
# Fills in the two placeholders in the site.
#
#   ./configure.sh "Devkal Technologies" "kifayat.help@gmail.com"
#
# Run this BEFORE the first push. The pages ship with __PUBLISHER__ and
# __CONTACT_EMAIL__ as literal placeholders so that a half-configured site is
# obviously broken rather than quietly wrong — a privacy policy with the wrong
# contact address is worse than no page at all.
#
# Safe to re-run: it rewrites from whatever is currently in the files, so pass
# the new values and it will replace the old ones only if they still match the
# placeholders. If you have already configured once and want to change a value,
# use git to revert first, or edit the files directly.

set -euo pipefail

PUBLISHER="${1:-}"
EMAIL="${2:-}"

if [ -z "$PUBLISHER" ] || [ -z "$EMAIL" ]; then
  echo "usage: ./configure.sh \"<publisher name>\" \"<contact email>\"" >&2
  echo >&2
  echo "  <publisher name>  exactly as it will appear as the Developer name" >&2
  echo "                    on your Play Store listing" >&2
  echo "  <contact email>   the address users write to for privacy and" >&2
  echo "                    deletion requests" >&2
  exit 1
fi

case "$EMAIL" in
  *@*.*) ;;
  *) echo "error: '$EMAIL' does not look like an email address" >&2; exit 1 ;;
esac

FILES="index.html privacy/index.html delete-account/index.html"

for f in $FILES; do
  [ -f "$f" ] || { echo "error: $f not found — run this from the repo root" >&2; exit 1; }
done

for f in $FILES; do
  # The email is also embedded in a mailto: query string, so it must survive
  # URL-encoding untouched — it does, because only the address itself is
  # substituted and the encoded subject/body around it are literal.
  sed -i.bak \
    -e "s|__PUBLISHER__|${PUBLISHER}|g" \
    -e "s|__CONTACT_EMAIL__|${EMAIL}|g" \
    "$f"
  rm -f "$f.bak"
  echo "  configured  $f"
done

echo
remaining=$(grep -l "__PUBLISHER__\|__CONTACT_EMAIL__" $FILES 2>/dev/null || true)
if [ -n "$remaining" ]; then
  echo "WARNING: placeholders still present in:" >&2
  echo "$remaining" >&2
  exit 1
fi

echo "Done. Publisher: $PUBLISHER"
echo "      Contact:   $EMAIL"
echo
echo "Next: git add -A && git commit -m 'Configure site' && git push"
