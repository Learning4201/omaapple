#!/usr/bin/env bash
set -euo pipefail

source_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$source_root"

QMLLINT=/usr/lib/qt6/bin/qmllint

command -v omarchy >/dev/null 2>&1 || {
  echo "test.sh: missing test command: omarchy" >&2
  exit 1
}
command -v rg >/dev/null 2>&1 || {
  echo "test.sh: missing test command: rg" >&2
  exit 1
}
[[ -x $QMLLINT ]] || {
  echo "test.sh: Qt 6 qmllint is missing: $QMLLINT" >&2
  exit 1
}

omarchy plugin validate .

mapfile -t qml_files < <(find . -name '*.qml' -not -path './.git/*' | sort)
if [[ ${#qml_files[@]} -eq 0 ]]; then
  echo "test.sh: no QML files to lint" >&2
  exit 1
fi

# Quickshell maps qs.Commons / qs.Ui onto the shell tree. qmllint needs a
# temporary qs/ prefix; do not put those symlinks in the plugin checkout
# (omarchy-plugin-validate forbids symlinks).
lint_imports=$(mktemp -d)
trap 'rm -rf "$lint_imports"' EXIT
mkdir -p "$lint_imports/qs"
ln -s /usr/share/omarchy/shell/Commons "$lint_imports/qs/Commons"
ln -s /usr/share/omarchy/shell/Ui "$lint_imports/qs/Ui"
"$QMLLINT" -I "$lint_imports" -I /usr/lib/qt6/qml "${qml_files[@]}"

# Runtime source only. Exclude globs must come last so they are not
# overridden by later include globs. This script is excluded because it
# lists the patterns. DNR rules.json is the allowed exception for Apple's
# private amp-api host.
fail_if_matches() {
  local label=$1
  shift
  if rg -n "$@" --glob '!scripts/test.sh' --glob '!.git/**' .; then
    echo "test.sh: forbidden pattern: $label" >&2
    exit 1
  fi
}

fail_if_matches "remote-debugging" \
  --glob '*.qml' --glob '*.js' --glob '*.sh' --glob '*.py' --glob '*.service' \
  -e 'remote-debugging'

fail_if_matches "--no-sandbox" \
  --glob '*.qml' --glob '*.js' --glob '*.sh' --glob '*.py' --glob '*.service' \
  -e '--no-sandbox'

fail_if_matches "BEGIN PRIVATE KEY" \
  --glob '*.qml' --glob '*.js' --glob '*.sh' --glob '*.py' --glob '*.service' --glob '*.pem' --glob '*.p8' \
  -e 'BEGIN PRIVATE KEY'

fail_if_matches "amp-api in REST clients" \
  --glob '*.qml' --glob '*.js' --glob '*.py' --glob '!playback/extension/rules.json' \
  -e 'amp-api\.music\.apple\.com'

fail_if_matches "ignore-certificate-errors" \
  --glob '*.qml' --glob '*.js' --glob '*.sh' --glob '*.py' --glob '*.service' \
  -e 'ignore-certificate-errors'

fail_if_matches "windowrulev2" \
  --glob '*.qml' --glob '*.js' --glob '*.sh' --glob '*.py' --glob '*.lua' --glob '*.service' \
  -e 'windowrulev2'

fail_if_matches "chromium-flags.conf" \
  --glob '*.qml' --glob '*.js' --glob '*.sh' --glob '*.py' --glob '*.service' \
  -e 'chromium-flags\.conf'

fail_if_matches "daily-browser extensions" \
  --glob '*.qml' --glob '*.js' --glob '*.sh' --glob '*.py' --glob '*.service' \
  -e 'copy-url|yt-dlp|whatsapp-slim'

fail_if_matches "heavyweight runtime dependency" \
  --glob '*.qml' --glob '*.js' --glob '*.sh' --glob '*.py' --glob '*.service' \
  -e 'QtWebEngine|WebEngineView|WebView|playerctl|node_modules'

fail_if_matches "hypr config write" \
  --glob '*.qml' --glob '*.js' --glob '*.sh' --glob '*.py' --glob '*.lua' \
  -e '~/\.config/hypr/'

fail_if_matches "NoNewPrivileges" \
  --glob '*.service' \
  -e 'NoNewPrivileges=true'

fail_if_matches "wrapper Chromium ExecStart" \
  --glob '*.service' \
  -e 'ExecStart=.*/usr/bin/chromium'

fail_if_matches "JWT on argv" \
  --glob '*.qml' --glob '*.js' --glob '*.sh' --glob '*.py' \
  --glob '!tests/**' \
  -e 'eyJ'

python3 "$source_root/tests/test_sign_token.py"

QMLTEST=/usr/lib/qt6/bin/qmltestrunner
if [[ -x $QMLTEST ]]; then
  QT_QPA_PLATFORM=offscreen "$QMLTEST" \
    -input "$source_root/tests/tst_api.qml" \
    -import "$source_root" \
    -o -,txt
fi

echo "All validation and tests passed."
