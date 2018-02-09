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
	setfont cyr-sun16
	locale-gen
  	export LANG=ru_RU.UTF-8
	clear
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
	color deepblue "Добро пожаловать в установщик ArchLinux v0.2, созданный h3xb0y :).">&2
	color deepblue "https://github.com/h3xb0y/arch-install" >&2
	color bold "Нажмите ENTER для продолжения..."
	read startinstall
    echo "$startinstall"
	clear
	color deepblue "Перед установкой создайте 4 раздела:"
	color deepblue "1) boot(100m)"
	color deepblue "2) swap(RAM)"
	color deepblue "3) root(>10G)"
	color deepblue "4) home"
	color bold "Нажмите ENTER для начала установки..."
	read startinstall
    echo "$startinstall"
	clear
    fdisk -l
    color default "Добавить раздел? y/n"    
    read answ
    if [ "$answ" == y ];then
        color default "Введите диск \e[32m/dev/sdX"
        read answ
        cfdisk $answ
    fi
    #boot
    color bold "Точка монтирования BOOT:"
    read BOOT
    #swap
    color bold "Точка монтирования SWAP:"
    read SWAP
    #root
    color bold "Точка монтирования ROOT:"
    read ROOT
    #home
    color bold "Точка монтирования HOME:"
    read HOME
    color default "Введите раздел для форматирования:"
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
                    color red "Ошибка! Введите еще раз..."
                ;;
            esac
        done
    color deepblue "монтирование..."
    mount $ROOT /mnt
    mkdir /mnt/{boot,home}
	mount $BOOT /mnt/boot
	mount $HOME /mnt/home
	swapon $SWAP
    clear
}

install(){
	#you need to use fresh version of archlinux
	color deepblue "скачивание пакетов..."
    pacstrap -i /mnt base base-devel
    pacstrap -i /mnt netctl dialog wpa_supplicant
	genfstab -p /mnt >> /mnt/etc/fstab
}

sysconfig(){
    genfstab -p /mnt >> /mnt/etc/fstab
	pacman -Syy
	#INSTALLING GRUB PACKAGE
	color cyan "Установить загрузчик GRUB? y/n"
    read grub
    if [ "$grub" == y ];then
    color default "Способ установки GRUB"
    select type in "BIOS" "EFI";do
            case $type in
                "BIOS")
                	color cyan "Установить os-prober?(желательно, если у вас установлена Windows) y/n"
    				read prober	   
    				if [ "$prober" == y ];then
    					arch-chroot /mnt pacman -S --noconfirm os-prober
    				fi
					color deepblue "скачивание GRUB пакетов..."
					arch-chroot /mnt pacman -S --noconfirm grub-bios 
					arch-chroot /mnt grub-install /dev/sda
        			arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
                    break
                ;;
                "EFI")
					color cyan "Установить os-prober?(желательно, если у вас установлена Windows) y/n"
    				read prober	   
    				if [ "$prober" == y ];then
    					arch-chroot /mnt pacman -S --noconfirm os-prober
    				fi
					color deepblue "скачивание GRUB пакетов..."
                   	arch-chroot /mnt pacman -S --noconfirm grub-efi-x86_64 
        			grub-install /dev/sda
        			arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
        			mkdir /mnt/boot/EFI/boot
        			cp /mnt/boot/EFI/arch_grub/grubx64.efi /mnt/boot/EFI/boot/bootx64.efi
                    break
                ;;
                *)
                    color red "Ошибка! Введите еще раз..."
                ;;
            esac
        done
	fi

	#PC'S NAME AND PASSWORD
	color cyan "Имя хоста"
    read host
    echo $host > /etc/hostname
    color cyan "Пароль root"
    passwd

    #LOCALTIME CONFIGURATION
    color yellow "Локализация"
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
    color cyan "Введите имя пользователя"
    read USER
    useradd -m -g wheel $USER
    usermod -aG root,bin,daemon,tty,disk,network,video,audio $USER
    color cyan "И пароль"
    passwd $USER
    pacman -S --noconfirm sudo
    sed -i 's/\# \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/g' /etc/sudoers
    sed -i 's/\# \%wheel ALL=(ALL) NOPASSWD: ALL/\%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

    #SETUP A VIDEOGRAPHIC DRIVER
    color cyan "Какую видеокарту Вы используете?"
    select GPU in "Intel" "Nvidia" "AMD" "driver for VirtuaBox";do
        case $GPU in
            "Intel")
                pacman -S --noconfirm xf86-video-intel -y
                break
            ;;
            "Nvidia")
                pacman -S --noconfirm xf86-video-nouveau -y
                break
            ;;
            "AMD")
                pacman -S --noconfirm xf86-video-ati -y
                break
            ;;
            "driver for VirtuaBox")
                pacman -S --noconfirm xf86-video-vesa -y
                break
            ;;
            *)
                color red "Ошибка! Введите еще раз..."
            ;;
        esac
    done
	
}

postinstall(){
	color cyan "еще немного..."
	arch-chroot /mnt mkinitcpio -p linux
	arch-chroot /mnt pacman -Syy
	arch-chroot /mnt pacman -Su
	arch-chroot /mnt pacman -S 
	arch-chroot /mnt sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-apps mesa-libgl xterm
	color cyan "Установить графическую оболочку XFCE4? y/n"
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
    color cyan "спасибо за юз    .88888888:."
    color cyan "моего скрипта   88888888.88888."
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
    color green   "Установка завершена, теперь введите:"
    color default "sudo systemctl reboot"
    color default "----------------------------------------------------------------------"
    color cyan "Если есть какие-нибудь ошибки или предложения, пишите здесь: https://github.com/h3xb0y/arch-installer/issues"
}

preinstall
install
sysconfig
postinstall

    

