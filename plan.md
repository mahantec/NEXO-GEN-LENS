# Gen Lens — implementation plan

## Scope
A plain local web application for extracting only these fields from the upper information table of English medical-record images/PDFs: Patient, ID, Referred by, Gender, Age, Sample type, Source, WES accession, Clinic number, Date collected, Date reported. It uses the uploaded PaddleOCR source/docs as implementation reference and PaddleOCR's official PP-OCRv6 inference pipeline. The uploaded archive contains source/configuration/docs (137 MB) but no pretrained model weights; official weights for orientation, detection, and recognition have been added under `data/models/official_models/`. Package libraries are installed automatically at first launch; only initial pip setup needs internet. No Manus-managed services, cloud OCR, LLM API, telemetry, or remote document processing are used.

## Architecture
- `app/server.py`: loopback-only FastAPI service with Host allowlist/security headers, indexed SQLite-persistent sequential work queue, isolated single OCR process, paginated job history, local file handling, editable review records, and disk-backed split-sheet Excel export.
- `app/ocr_engine.py`: PaddleOCR initialization, PDF/image decoding, small-skew correction, crop to upper page area, OCR adapter, and strict allowlisted label/value extraction.
- `app/static/`: RTL Persian interface with drag/drop batch intake, progress, editable per-field review, completeness gating, and export.
- `data/inbox/`: local uploaded source files; `data/genlens.sqlite3`: local job/record state; `data/models/`: locally stored weights/cache.
- `start_genlens.sh` and `start_genlens.bat`: one-click setup/launch, automatic dependency install, bundled local model cache, and browser open; bind only to 127.0.0.1.
- `references/paddleocr/`: the user-supplied extracted PaddleOCR code and docs; not required as a runtime dependency if the package install succeeds.

## Design
Three style alternatives: clinical Swiss utility (<10%), editorial lab notebook (<10%), quiet precision console (<10%). Chosen: **quiet precision console**.
- Design movement: restrained clinical software with precise data-entry affordances, not a consumer medical portal.
- Core principles: legibility first; calm but explicit status; progressive disclosure; keyboard-friendly editing.
- Color philosophy: warm neutral canvas and dark ink for long-session comfort, with teal for trusted actions and amber/red only for review/error.
- Layout paradigm: narrow header with a wide intake strip, followed by a vertically stacked processing queue and an expandable review panel per case.
- Signature elements: compact local-processing status badge; monospaced accession/date values; softly outlined drag-and-drop intake zone.
- Interaction philosophy: one drop action starts processing; uncertainty is visible rather than silently guessed; users can edit values before confirmation.
- Animation: brief opacity/height transitions; no continuous motion or heavy effects.
- Typography: system sans-serif for Persian/English UI; system monospace for identifiers; clear 12/14/20/28px hierarchy.
- Brand essence: private, local-first extraction for genetics laboratory staff; precise, calm, accountable.
- Brand voice: direct Persian UI labels. Examples: «پرونده‌ها را اینجا رها کنید» and «برای خروجی، همهٔ فیلدها را بررسی و تأیید کنید».
- Wordmark: “gen” lowercase with a small corner-frame lens mark followed by “lens”.
- Signature brand color: deep teal.

## Project structure
See architecture above; app files remain separate by server, OCR, UI, launch scripts, and local data. Uploaded case material is excluded from distributed source bundles.

## Material constraints
OCR cannot guarantee perfect transcription or non-empty values. Records with missing/uncertain values must be reviewed and explicitly confirmed before export; no value is invented. CPU OCR uses a separate single worker process so inference does not block localhost API responses; job pages and Excel generation are bounded-memory. Thousands of images are queueable but take a long time on CPU; millions still require substantial time, disk, and operational monitoring, not one interactive upload session. OCR inference weights are bundled locally; first-time Python dependency installation needs internet.
