#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
PORT="${GENLENS_PORT:-8765}"
PYTHON="${PYTHON:-python3}"

"$PYTHON" - <<'PY'
import sys
if sys.version_info < (3, 10) or sys.version_info >= (3, 13):
    print(f"Gen Lens needs Python 3.10–3.12; found {sys.version.split()[0]}", file=sys.stderr)
    raise SystemExit(2)
PY

if [[ ! -x .venv/bin/python ]]; then
  echo "Creating the Gen Lens private Python environment…"
  "$PYTHON" -m venv .venv
fi
if ! .venv/bin/python -c 'import paddleocr, fastapi, openpyxl, cv2, pymupdf' >/dev/null 2>&1; then
  echo "Installing PaddleOCR and local app dependencies (internet required once)…"
  .venv/bin/python -m pip install --upgrade pip
  .venv/bin/python -m pip install -r requirements.txt
fi
mkdir -p data/inbox data/models
export PADDLE_PDX_CACHE_HOME="$ROOT/data/models"
if python3 -c 'import socket,sys;s=socket.socket();s.settimeout(.3);sys.exit(0 if s.connect_ex(("127.0.0.1",int(sys.argv[1])))==0 else 1)' "$PORT"; then
  echo "Port $PORT is already in use. If Gen Lens is already running, opening it now."
  (xdg-open "http://127.0.0.1:$PORT" >/dev/null 2>&1 || true)
  exit 0
fi
( sleep 1.5; xdg-open "http://127.0.0.1:$PORT" >/dev/null 2>&1 || true ) &
echo "Gen Lens is local at http://127.0.0.1:$PORT"
echo "Bundled PaddleOCR model weights are loaded from ./data/models (no OCR model download needed)."
echo "Press Ctrl+C to stop. Uploaded records remain in ./data until deleted."
exec .venv/bin/python -m uvicorn app.server:app --host 127.0.0.1 --port "$PORT" --no-access-log
