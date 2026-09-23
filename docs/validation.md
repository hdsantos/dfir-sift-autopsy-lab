# Environment Validation

Complete this validation **before the laboratory session**.

## 1. Automated pre-check

From the repository root:

```bash
chmod +x scripts/check-environment.sh
./scripts/check-environment.sh
```

The script checks the main version, package, command, directory, and permission assumptions. It cannot prove that the entire forensic stack is operational.

## 2. Manual functional validation

- [ ] Autopsy 4.x opens as a desktop application.
- [ ] A **New Case** can be created.
- [ ] **Add Data Source** accepts a known test image.
- [ ] The file tree is populated after ingest.
- [ ] No `Solr Keyword Search Service Error` is displayed.
- [ ] Files can be browsed and basic metadata inspected.
- [ ] The VM is shut down cleanly after validation.
- [ ] A VM snapshot is created once the environment is confirmed working.

## 3. Recommended snapshot

Create a snapshot with a clear name such as:

```text
DFIR-LAB-READY
```

This provides a known-good recovery point before exercises and evidence analysis begin.

## Important

Do not use the course evidence files as your first installation test. Use a small known-good test image so that installation problems are not confused with evidence-analysis problems.
