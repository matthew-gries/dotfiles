# dotfiles

How to setup i3.

Install i3-gaps.
Install compton, feh, ranger via Pacman
Install polybar, multilockscreen-git, dmenu2 via AUR

Copy .fonts from this repo into home directory.

Download st-0.8.2 from website and extract.
Download the st-aplha, st-scrollback, and st-scrollback-mouse patches and use git apply
to apply the patches. You may need to do git apply --reject on the mouse patch and manually add
in some lines (like extern MouseKey mkeys[] in st.h)
Copy config.h from this repo into st folder, then run sudo make clean install.

Create .wallpaper dir in home, then move whatever image you want to be your wallpaper into this folder.
Name the image wallpaper.jpg

Copy .vimrc and .bashrc into home.
Copy nvim folder into .config
Copy i3, polybar, and conky (not using that right now so not necessary) into config folder.
Move whatever you want the lock screen to be into the i3 folder and name it lock.jpg.
Run multilockscreen -u lock.jpg --fx dim,pixel
Make sure lockscreen.sh is executable

Go into .config/polybar, in the nord-config file make sure the correct network interface is selected.
In nord-down, make sure the hwmon-path points to a file in /sys/devices called temp1_input. You may need to run
sudo find /sys/devices -name "temp1_input" to find it (or another device file can be used). You also may need to install
lm-sensors

Copy the i3lock.service file into /etc/systemd/system and run
sudo systemctl enable i3lock.service
sudo systemctl start i3lock.service

Exit all windows and press mod+shift+R to load everything.
