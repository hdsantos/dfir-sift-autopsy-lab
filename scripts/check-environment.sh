#!/usr/bin/env bash

# DFIR Lab environment pre-check
# This script is intentionally read-only: it reports issues but does not modify the host.

set -u

OK=0
WARN=0
FAIL=0

ok()   { printf '[OK]   %s\n' "$1"; OK=$((OK+1)); }
warn() { printf '[WARN] %s\n' "$1"; WARN=$((WARN+1)); }
fail() { printf '[FAIL] %s\n' "$1"; FAIL=$((FAIL+1)); }

printf 'DFIR Lab Environment Check\n'
printf '%s\n' '──────────────────────────'

# OS
if command -v lsb_release >/dev/null 2>&1; then
    rel="$(lsb_release -rs 2>/dev/null || true)"
    if [[ "$rel" == "22.04" ]]; then
        ok "Ubuntu 22.04 detected"
    else
        warn "Ubuntu release is ${rel:-unknown}; course guide was validated on 22.04"
    fi
else
    warn "lsb_release not available; Ubuntu version not verified"
fi

# Java
if command -v java >/dev/null 2>&1; then
    jver="$(java -version 2>&1 | head -n1)"
    if [[ "$jver" == *'17.'* || "$jver" == *'"17"'* ]]; then
        ok "Java 17 detected ($jver)"
    else
        warn "Java detected but not clearly Java 17 ($jver)"
    fi
else
    fail "Java not found"
fi

# Cast
if command -v cast >/dev/null 2>&1; then
    ok "Cast installed ($(command -v cast))"
else
    fail "Cast command not found"
fi

# SIFT indicators / useful tools
found_sift=0
for cmd in volatility3.py vol.py ewfinfo bulk_extractor exiftool; do
    if command -v "$cmd" >/dev/null 2>&1; then
        found_sift=1
        break
    fi
done
if [[ $found_sift -eq 1 ]]; then
    ok "Forensic tooling detected in PATH"
else
    warn "No selected SIFT tool indicator found in PATH; verify the SIFT installation manually"
fi

# Autopsy installation
AUTOPSY_ROOT="$HOME/autopsy/autopsy-4.22.1"
AUTOPSY_BIN="$AUTOPSY_ROOT/bin/autopsy"
if [[ -x "$AUTOPSY_BIN" ]]; then
    ok "Autopsy 4.22.1 launcher detected"
elif [[ -d "$HOME/autopsy" ]]; then
    warn "~/autopsy exists, but expected 4.22.1 launcher was not found"
else
    fail "Autopsy installation directory not found under ~/autopsy"
fi

# sleuthkit-java
if dpkg-query -W -f='${Status} ${Version}\n' sleuthkit-java 2>/dev/null | grep -q '^install ok installed'; then
    sk="$(dpkg-query -W -f='${Version}' sleuthkit-java 2>/dev/null || true)"
    ok "sleuthkit-java installed (${sk:-version unknown})"
else
    fail "sleuthkit-java is not installed according to dpkg"
fi

# Package hold
if apt-mark showhold 2>/dev/null | grep -qx 'sleuthkit-java'; then
    ok "sleuthkit-java is held"
else
    warn "sleuthkit-java is not marked as held"
fi

# Libraries
for pkg in libewf libvhdi libvmdk; do
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed'; then
        ver="$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null || true)"
        ok "$pkg installed (${ver:-version unknown})"
    else
        fail "$pkg not installed"
    fi
done

# Ownership
if [[ -d "$HOME/autopsy" ]]; then
    owner="$(stat -c '%U' "$HOME/autopsy" 2>/dev/null || true)"
    if [[ "$owner" == "$USER" ]]; then
        ok "~/autopsy is owned by current user"
    else
        fail "~/autopsy owner is '${owner:-unknown}', expected '$USER'"
    fi
fi

# Solr
SOLR="$AUTOPSY_ROOT/autopsy/solr/bin/solr"
if [[ -x "$SOLR" ]]; then
    ok "Embedded Solr launcher detected"
else
    warn "Embedded Solr launcher not found at expected path"
fi

printf '\nSummary: %d OK, %d warning(s), %d failure(s)\n' "$OK" "$WARN" "$FAIL"
printf 'Complete docs/validation.md before using the environment for course evidence.\n'

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
