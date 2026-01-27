**Install Plasma Mobile on the Chuwi Hi8 (Debian 12)**

This guide explains how to install Debian 12 with KDE Plasma, enable the GSL1680 touchscreen firmware for the Chuwi Hi8 tablet, install Plasma Mobile from the standard Debian repository, switch to the Plasma Mobile Wayland session, and enable autologin using a custom script.

1. Install Debian 12 with KDE Plasma
Download Debian 12 ISO, install the system normally, and when prompted for the desktop environment select KDE Plasma.
Debian will automatically install SDDM as the default display manager.
✔ Add sudo privileges to your user (important)
On some Debian 12 installations, the user created during setup is not automatically added to the sudo group.
If, after installation, you see messages like “user is not in the sudoers file”, you must manually enable sudo privileges.
Follow these steps:
      A. Boot into Recovery Mode
      Reboot the device.
      In the GRUB menu, select Advanced options for Debian.
      Choose the entry ending with (recovery mode).
      Select the option that opens a root shell.
      
      B. Add your user to the sudo group
      Replace yourusername with your actual username:
        usermod -aG sudo yourusername
      Verify that the user is now in the sudo group:
        groups yourusername
      You should see sudo in the output.
      
      C. Reboot normally
        sudo reboot
      Your user now has full sudo access, and you can proceed with installing Plasma Mobile, copying firmware, and running configuration scripts.

2. Install the Touchscreen Firmware (GSL1680 – Chuwi Hi8)
The Chuwi Hi8 uses a Silead GSL1680 touchscreen.
Download the firmware file gsl1680-chuwi-hi8.fw and place it in the correct directory.
Create the firmware path:
  sudo mkdir -p /lib/firmware/silead
Copy the firmware:
  sudo cp ~/Downloads/gsl1680-chuwi-hi8.fw /lib/firmware/silead/
Set permissions:
  sudo chmod 644 /lib/firmware/silead/gsl1680-chuwi-hi8.fw
Update initramfs:
  sudo update-initramfs -u
Reboot:
  sudo reboot
After reboot, the touchscreen should work.

4. Install Plasma Mobile
Plasma Mobile is included in the default Debian 12 repository.
Install the base environment:
  sudo apt update
  sudo apt install plasma-mobile
Or install the full environment:
  sudo apt install plasma-mobile-full

5. Switch to the Plasma Mobile Wayland Session
Log out from your current KDE Plasma session.
At the login screen (SDDM), open the session selector (gear icon).
Choose Plasma Mobile (Wayland) and log in.

6. Enable Autologin (autologin script)
Here is the full script that enables SDDM autologin specifically for Plasma Mobile (Wayland).
Save it as: enable_autologin_plasma_mobile_wayland.sh

    set -euo pipefail
    
    TARGET_USER="${1:-YOUR_USERNAME}"
    CONF_DIR="/etc/sddm.conf.d"
    CONF_FILE="${CONF_DIR}/10-autologin-plamo.conf"
    
    if [[ "$EUID" -ne 0 ]]; then
      echo "Run as root: sudo $0 <username>"
      exit 1
    fi
    
    if ! id -u "$TARGET_USER" >/dev/null 2>&1; then
      echo "User '$TARGET_USER' does not exist."
      exit 1
    fi
    
    if ! command -v sddm >/dev/null 2>&1; then
      echo "Installing SDDM..."
      apt update
      apt install -y sddm
    fi
    
    WAYLAND_DIR="/usr/share/wayland-sessions"
    SESSION_FILE=""
    
    if ls -1 "${WAYLAND_DIR}/"plasma-mobile*.desktop >/dev/null 2>&1; then
      SESSION_FILE="$(ls -1 ${WAYLAND_DIR}/plasma-mobile*.desktop | head -n1)"
    elif ls -1 "${WAYLAND_DIR}/"plasmawayland*.desktop >/dev/null 2>&1; then
      SESSION_FILE="$(ls -1 ${WAYLAND_DIR}/plasmawayland*.desktop | head -n1)"
    elif ls -1 "${WAYLAND_DIR}/"plasma*.desktop >/dev/null 2>&1; then
      SESSION_FILE="$(ls -1 ${WAYLAND_DIR}/plasma*.desktop | head -n1)"
    else
      SESSION_FILE="$(ls -1 ${WAYLAND_DIR}/*.desktop | head -n1 || true)"
    fi
    
    if [[ -z "${SESSION_FILE}" ]]; then
      echo "No Wayland session found in ${WAYLAND_DIR}"
      exit 1
    fi
    
    SESSION_NAME="$(basename "${SESSION_FILE}")"
    
    mkdir -p "${CONF_DIR}"
    
    cat > "${CONF_FILE}" <<EOF
    [Autologin]
    User=${TARGET_USER}
    Session=${SESSION_NAME}
    Relogin=false
    EOF
    
    chmod 644 "${CONF_FILE}"
    
    systemctl enable sddm.service >/dev/null 2>&1 || true
    
    echo "Autologin enabled for ${TARGET_USER} on session ${SESSION_NAME}."
    echo "Reboot to apply changes."

Make it executable and run it:
  chmod +x enable_autologin_plasma_mobile_wayland.sh
  sudo ./enable_autologin_plasma_mobile_wayland.sh yourusername

Then reboot:
  sudo reboot

Done!
You now have:
