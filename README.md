**Install Plasma Mobile on the Chuwi Hi8 (Debian 12)**

This guide explains how to install Debian 12 with KDE Plasma, enable the Silead GSL1680 touchscreen firmware for the Chuwi Hi8 tablet, install Plasma Mobile from the standard Debian repository, switch to the Plasma Mobile Wayland session, and enable autologin using a custom script.

1. Install Debian 12 with KDE Plasma
Download Debian 12 ISO, install the system normally (Rufus for flashing, ESC on Booting and choose USB as start), and when prompted for the desktop environment select KDE Plasma.
Debian will automatically install SDDM as the default display manager.

✔ Add sudo privileges to your user (important)
On some Debian 12 installations, the user created during setup is not automatically added to the sudo group.
If, after installation, you see messages like “user is not in the sudoers file”, you must manually enable sudo privileges.
Follow these steps:

A. Boot into Recovery Mode
Boot Chuwi Hi8 and in the GRUB menu, select Advanced options for Debian.
Choose the entry ending with (recovery mode) and a root shell starts automatically, insert your root password.      
B. Add your user to the sudo group
Replace 'yourusername' with your actual username, the same that you put in the installation:
      
      usermod -aG sudo yourusername
            
Verify that the user is now in the sudo group:
      
      groups yourusername
            
You should see sudo in the output.      
C. Reboot normally
      
      sudo reboot     
        
Your user now has full sudo access, and you can proceed with installing Plasma Mobile, 
copying firmware, and running configuration scripts.

3. Install the Touchscreen Firmware (GSL1680 – Chuwi Hi8)
The Chuwi Hi8 uses a Silead GSL1680 touchscreen.
Download the firmware file gsl1680-chuwi-hi8.fw and place it in the correct directory.

Create the firmware path:

      sudo mkdir -p /lib/firmware/silead
  
Download the firmware and copy in /lib/firmware/silead:

      sudo cp ~/Downloads/gsl1680-chuwi-hi8.fw /lib/firmware/silead/
  
Set permissions:

      sudo chmod 644 /lib/firmware/silead/gsl1680-chuwi-hi8.fw
  
Update initramfs:

      sudo update-initramfs -u
  
Reboot:

      sudo reboot
  
After reboot, the touchscreen should work.

5. Install Plasma Mobile
Plasma Mobile is included in the default Debian 12 repository.
Install the base environment:

       sudo apt update
       sudo apt install plasma-mobile
  
Or install the full environment:

      sudo apt install plasma-mobile-full

6. Switch to the Plasma Mobile Wayland Session
Log out from your current KDE Plasma session.
At the login screen (SDDM), open the session selector (gear icon).
Choose Plasma Mobile (Wayland) and log in.

8. Enable Autologin (autologin script)
Attachted is the full script that enables SDDM autologin specifically for Plasma Mobile (Wayland).

Make it executable and run it:

      chmod +x enable_autologin_plasma_mobile_wayland.sh
      sudo ./enable_autologin_plasma_mobile_wayland.sh yourusername

Then reboot:

      sudo reboot

Done!
You now have:
