# Contributing

This repository supports a teaching environment, so reproducibility is more important than tracking the newest release.

## Before changing a validated version

1. Test the change on a clean Ubuntu VM.
2. Run the full installation procedure.
3. Run `scripts/check-environment.sh`.
4. Complete `docs/validation.md` with a known-good forensic image.
5. Record the change and any migration notes in `CHANGELOG.md`.

## Documentation changes

Please keep commands copy/paste friendly and explain any step that intentionally bypasses normal package dependency handling.

## Evidence files

Do not commit forensic images, memory dumps, PCAPs, VM disks, or other large evidence files directly unless there is a deliberate repository policy for them. Prefer documented download locations plus cryptographic hashes.
