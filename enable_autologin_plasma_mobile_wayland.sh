#!/usr/bin/env bash
set -euo pipefail

# === Configurazione: imposta l'utente qui o passalo come $1 ===
TARGET_USER="${1:-TUO_UTENTE}"
CONF_DIR="/etc/sddm.conf.d"
CONF_FILE="${CONF_DIR}/10-autologin-plamo.conf"

# --- Controlli preliminari ---
if [[ "$EUID" -ne 0 ]]; then
  echo "Esegui come root: sudo $0 <utente>"
  exit 1
fi

if ! id -u "$TARGET_USER" >/dev/null 2>&1; then
  echo "Errore: utente '$TARGET_USER' inesistente."
  exit 1
fi

if ! command -v sddm >/dev/null 2>&1; then
  echo "SDDM non trovato. Installo sddm..."
  apt update
  apt install -y sddm
fi

# --- Rilevamento sessione Wayland ---
WAYLAND_DIR="/usr/share/wayland-sessions"
if [[ ! -d "$WAYLAND_DIR" ]]; then
  echo "Errore: directory ${WAYLAND_DIR} non trovata. Plasma Mobile Wayland non sembra installata."
  echo "Installa i pacchetti plasma-mobile/plasma-mobile-full da unstable e riprova."
  exit 1
fi

# Preferenze di matching: plasma-mobile > plasma (Wayland standard) > altra qualsiasi sessione Wayland
SESSION_FILE=""
if ls -1 "${WAYLAND_DIR}/"plasma-mobile*.desktop >/dev/null 2>&1; then
  SESSION_FILE="$(ls -1 ${WAYLAND_DIR}/plasma-mobile*.desktop | head -n1)"
elif ls -1 "${WAYLAND_DIR}/"plasmawayland*.desktop >/dev/null 2>&1; then
  SESSION_FILE="$(ls -1 ${WAYLAND_DIR}/plasmawayland*.desktop | head -n1)"
elif ls -1 "${WAYLAND_DIR}/"plasma*.desktop >/devnull 2>&1; then
  SESSION_FILE="$(ls -1 ${WAYLAND_DIR}/plasma*.desktop | head -n1)"
else
  # ultima spiaggia: qualsiasi sessione Wayland disponibile
  SESSION_FILE="$(ls -1 ${WAYLAND_DIR}/*.desktop | head -n1 || true)"
fi

if [[ -z "${SESSION_FILE}" ]]; then
  echo "Errore: nessuna sessione Wayland trovata in ${WAYLAND_DIR}."
  exit 1
fi

SESSION_NAME="$(basename "${SESSION_FILE}")"  # includiamo .desktop, come raccomandato da Debian Wiki

echo "→ User: ${TARGET_USER}"
echo "→ Sessione Wayland scelta: ${SESSION_NAME}"

# --- Scrittura configurazione SDDM ---
mkdir -p "${CONF_DIR}"

# Backup se esiste
if [[ -f "${CONF_FILE}" ]]; then
  cp -a "${CONF_FILE}" "${CONF_FILE}.bak.$(date +%Y%m%d%H%M%S)"
fi

cat > "${CONF_FILE}" <<EOF
[Autologin]
User=${TARGET_USER}
Session=${SESSION_NAME}
Relogin=false
EOF

chmod 644 "${CONF_FILE}"

# --- Abilitazione sddm a boot ---
systemctl enable sddm.service >/dev/null 2>&1 || true

echo
echo "Configurazione completata."
echo "File creato: ${CONF_FILE}"
echo "Contenuto:"
echo "--------------------------------"
cat "${CONF_FILE}"
echo "--------------------------------"
echo "Riavvia per verificare l'autologin in Plasma Mobile (Wayland)."