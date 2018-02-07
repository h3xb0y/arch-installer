#!/bin/bash

# simple arch-installer
color(){
    case $1 in 
    	deepblue)
        	echo -e "\e[94m$2\033[0m"
         ;;       
        green)
        	echo -e "\033[32m$2\033[0m"
        ;;
        red)
            echo -e "\033[31m$2\033[0m"
        ;;
        cyan)
            echo -e "\e[36m$2\033[0m"
        ;;       
        bold)
            echo -e "\e[1m$2\033[0m"
         ;;
        default)
			echo -e "\e[39m$2\033[0m"
    esac
}
preinstall(){
	loadkeys ru
	export LANG=ru_RU.UTF-8
	locale-gen
	color cyan "Тест.АаБбВвГгДд"
	echo -e "" >&2
	color cyan "	              -'" >&2
	color cyan "                 .o+'" >&2
	color cyan "                'ooo/" >&2
	color cyan "               '+oooo:" >&2
	color cyan "              '+oooooo:" >&2
	color cyan "              -+oooooo+:" >&2
	color cyan "            '/:-:++oooo+:" >&2
	color cyan "           '/++++/+++++++:" >&2
	color cyan "          '/++++++++++++++:" >&2
	color cyan "         '/+++ooooooooooooo/'" >&2
	color cyan "        ./ooosssso++osssssso+'" >&2
	color cyan "       .oossssso-''''/ossssss+'" >&2
	color cyan "      -osssssso.      :ssssssso." >&2
	color cyan "     :osssssss/        osssso+++." >&2
	color cyan "    /ossssssss/        +ssssooo/-" >&2
	color cyan "  '/ossssso+/:-        -:/+osssso+-" >&2
	color cyan " '+sso+:-'                 '.-/+oso:" >&2
	color cyan "'++:.                           '-/+/" >&2
	color cyan ".'                                 '" >&2
	color deepblue "Welcome to arch-installer v0.1, a script maded by h3xb0y :).">&2
	color deepblue "https://github.com/h3xb0y/arch-install" >&2
	color bold "Press ENTER to skip..."
	read startinstall
    echo "$startinstall"
	clear
	color deepblue "Before installation u must to create 4 partritions:"
	color deepblue "1) boot(100m)"
	color deepblue "2) swap(your ram)"
	color deepblue "3) root(>10G)"
	color deepblue "4) home"
	color bold "Press ENTER to start installation..."
	read startinstall
    echo "$startinstall"
	clear
    fdisk -l
    color default "Add the partrition? y/n"    
    read answ
    if [ "$answ" == y ];then
        color default "Okay, now input the disk \e[32m/dev/sdX"
        read answ
        cfdisk $answ
    fi
    #boot
    color bold "BOOT mount point:"
    read BOOT
    #swap
    color bold "SWAP mount point:"
    read SWAP
    #root
    color bold "ROOT mount point:"
    read ROOT
    #home
    color bold "HOME mount point:"
    read HOME
    color default "Enter partrition to format:"
    select type in "boot" "swap" "root" "home" "format all" "start installation";do
            case $type in
                "boot")
                	umount $BOOT > /dev/null 2>&1
        			mkfs.ext2 $BOOT -L boot
                ;;
                "swap")
                    umount $SWAP > /dev/null 2>&1
        			mkswap $SWAP -L swap
                ;;
                "root")
                    umount $ROOT > /dev/null 2>&1
        			mkfs.ext4 $ROOT -L root
                ;;
                "home")
                    umount $HOME > /dev/null 2>&1
        			mkfs.ext4 $HOME -L home
                ;;
                "format all")
                    umount $BOOT > /dev/null 2>&1
                    mkfs.ext2 $BOOT -L boot
                    umount $SWAP > /dev/null 2>&1
                    mkswap $SWAP -L swap
                    umount $ROOT > /dev/null 2>&1
                    mkfs.ext4 $ROOT -L root
                    umount $HOME > /dev/null 2>&1
                    mkfs.ext4 $HOME -L home
                ;;
                "start installation")
                    break
                ;;
                *)
                    color red "Error! Input a valid command..."
                ;;
            esac
        done
    color deepblue "mounting..."
    mount $ROOT /mnt
    mkdir /mnt/{boot,home}
	mount $BOOT /mnt/boot
	mount $HOME /mnt/home
	swapon $SWAP
    clear
}

install(){
	#you need to use fresh version of archlinux
	color deepblue "downloading packages..."
    pacstrap -i /mnt base base-devel
    pacstrap -i /mnt netctl dialog wpa_supplicant
	genfstab -p /mnt >> /mnt/etc/fstab
}

sysconfig(){
    genfstab -p /mnt >> /mnt/etc/fstab
	pacman -Syy
	#INSTALLING GRUB PACKAGE
	color cyan "Install GRUB? y/n"
    read grub
    if [ "$grub" == y ];then
    color default "Choose grub setting"
    select type in "BIOS" "EFI";do
            case $type in
                "BIOS")	   
					color deepblue "installing grub package..."
					arch-chroot /mnt pacman -S grub-bios 
					arch-chroot /mnt grub-install /dev/sda
        			arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
                    break
                ;;
                "EFI")
				color deepblue "installing grub package..."
                   	arch-chroot /mnt pacman -S grub-efi-x86_64 
        			grub-install /dev/sda
        			arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
        			mkdir /mnt/boot/EFI/boot
        			cp /mnt/boot/EFI/arch_grub/grubx64.efi /mnt/boot/EFI/boot/bootx64.efi
                    break
                ;;
                *)
                    color red "Error! Input a valid command..."
                ;;
            esac
        done
	fi

	#PC'S NAME AND PASSWORD
	color cyan "Input your hostname"
    read host
    echo $host > /etc/hostname
    color cyan "Enter your root pass"
    passwd

    #LOCALTIME CONFIGURATION
    color yellow "Choose your local time"
    select localtime in 'ls /usr/share/zoneinfo';do
        if [ -d '/usr/share/zoneinfo/$localtime' ];then
            select time in 'ls /usr/share/zoneinfo/$localtime';do
                ln -sf /usr/share/zoneinfo/$localtime/$time /etc/localtime
                break
            done
        else
            ln -sf /usr/share/zoneinfo/$localtime /etc/localtime
            break
        fi
        break
    done

    #ADDING USER
    color cyan "Input the user name you want to use"
    read USER
    useradd -m -g wheel $USER
    usermod -aG root,bin,daemon,tty,disk,network,video,audio $USER
    color cyan "Set the password"
    passwd $USER
    pacman -S --noconfirm sudo
    sed -i 's/\# \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/g' /etc/sudoers
    sed -i 's/\# \%wheel ALL=(ALL) NOPASSWD: ALL/\%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

    #SETUP A VIDEOGRAPHIC DRIVER
    color cyan "What is your video graphic card?"
    select GPU in "Intel" "Nvidia" "AMD" "driver for VirtuaBox";do
        case $GPU in
            "Intel")
                pacman -S --noconfirm xf86-video-intel -y
                break
            ;;
            "Nvidia")
                pacman -S xf86-video-nouveau -y
                break
            ;;
            "AMD")
                pacman -S --noconfirm xf86-video-ati -y
                break
            ;;
            "driver for VirtuaBox")
                pacman -S xf86-video-vesa -y
                break
            ;;
            *)
                color red "Error! Please input the correct num"
            ;;
        esac
    done
	
}

postinstall(){
	color cyan "a bit more..."
	arch-chroot /mnt mkinitcpio -p linux
	arch-chroot /mnt pacman -Syy
	arch-chroot /mnt pacman -Su
	arch-chroot /mnt pacman -S 
	arch-chroot /mnt sudo pacman -S xorg-server xorg-xinit xorg-apps mesa-libgl xterm
	color cyan "Install XFCE4? y/n"
    read xfce
    if [ "$xfce" == y ];then
    		arch-chroot /mnt pacman -S xfce4 xfce4-goodies sddm
            arch-chroot /mnt systemctl enable sddm.service
    fi
    arch-chroot /mnt pacman -Sy
    arch-chroot /mnt pacman -S --noconfirm archlinuxcn-keyring
    arch-chroot /mnt pacman -S --noconfirm yaourt
    arch-chroot /mnt sudo pacman -S ttf-liberation ttf-dejavu opendesktop-fonts ttf-bitstream-vera ttf-arphic-ukai ttf-arphic-uming ttf-hanazono
    arch-chroot /mnt systemctl enable dhcpcd
    color cyan "thx for using    .88888888:."
    color cyan "my script       88888888.88888."
    color cyan "<3            .8888888888888888."
    color cyan "              888888888888888888"
    color cyan "              88' _'88'_  '88888"
    color cyan "              88 88 88 88  88888"
    color cyan "              88_88_::_88_:88888"
    color cyan "              88:::,::,:::::8888"
    color cyan "              88':::::::::''8888"
    color cyan "             .88  '::::'    8:88."
    color cyan "            8888            '8:888."
    color cyan "          .8888'             '888888."
    color cyan "         .8888:..  .::.  ...:'8888888:."
    color cyan "        .8888.'     :'     ''::'88:88888"
    color cyan "       .8888        '         '.888:8888."
    color cyan "      888:8         .           888:88888"
    color cyan "    .888:88        .:           888:88888:"
    color cyan "    8888888.       ::           88:888888"
    color cyan "   '.::.888.      ::          .88888888"
    color cyan "  .::::::.888.    ::         :::'8888'.:."
    color cyan " ::::::::::.888   '         .::::::::::::"
    color cyan " ::::::::::::.8    '      .:8::::::::::::."
    color cyan ".::::::::::::::.        .:888:::::::::::::"
    color cyan " :::::::::::::::88:.__..:88888:::::::::::'"
    color cyan "  ''.:::::::::::88888888888.88:::::::::'"
    color cyan "        '':::_:' -- '' -'-' '':_::::''"
    color green   "Installation complete. Now run the command"
    color default "sudo systemctl reboot"
    color default "----------------------------------------------------------------------"
    color cyan "if you have any errors or offers, write here: https://github.com/h3xb0y/arch-installer/issues"
}

preinstall
install
sysconfig
postinstall

    

