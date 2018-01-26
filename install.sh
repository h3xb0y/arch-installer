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
	color deepblue "Welcome to arch-installer, a script maded by h3xb0y :).">&2
	color deepblue "This script perform an automatic install of Archlinux." >&2
	color deepblue "Pretty simple, it only ask you for hostname, username," >&2
	color deepblue "password, which disk to use, required partitions size," >&2
	color deepblue "language and if you wish or not to install xfce4">&2
	color bold "Press ENTER to skip..."
	read startinstall
	clear
	color deepblue "Before installation u must to create 4 partritions:"
	color deepblue "1) boot(100m)"
	color deepblue "2) swap(your ram)"
	color deepblue "3) root(>10G)"
	color deepblue "4) home"
	color bold "Press ENTER to start installation..."
	read startinstall
	clear
    fdisk -l
    color default "Add the partrition? \e[32my\e[39m/\e[31mn"    
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
    color bold "SWAP:"
    read SWAP
    #root
    color bold "ROOT mount point:"
    read ROOT
    #home
    color bold "HOME mount point:"
    read HOME
    color default "Enter partrition to format:"
    select type in "boot" "swap" "root" "home" "skip";do
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
                "skip")
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
    pacstrap /mnt base base-devel grub
	genfstab -p /mnt >> /mnt/etc/fstab
}

sysconfig(){
	#INSTALLING GRUB PACKAGE
	color cyan "Install GRUB? y/n"
    read grub
    if [ "$grub" == y ];then
    color default "Choose grub setting"
    select type in "BIOS" "EFI";do
            case $type in
                "BIOS")	   
					color deepblue "installing grub package..."
					pacman -S --noconfirm grub
					rub-install --target=i386-pc $TMP
        			grub-mkconfig -o /boot/grub/grub.cfg
					break
                ;;
                "EFI")
					color deepblue "installing grub package..."
                   	pacman -S --noconfirm grub efibootmgr -y
        			grub-install --target=`uname -m`-efi --efi-directory=/boot --bootloader-id=Arch
        			grub-mkconfig -o /boot/grub/grub.cfg
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
    color cyan "Enter your root password"
    passwd

    #LOCALTIME CONFIGURATION
    color yellow "Choose your local time"
    select localtime in `ls /usr/share/zoneinfo`;do
        if [ -d "/usr/share/zoneinfo/$localtime" ];then
            select time in `ls /usr/share/zoneinfo/$localtime`;do
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
    dolor cyan "Input the user name you want to use (must be lower case)"
    read USER
    useradd -m -g wheel $USER
    usermod -aG root,bin,daemon,tty,disk,network,video,audio $USER
    color cyan "Set the passwd"
    passwd $USER
    pacman -S --noconfirm sudo
    sed -i 's/\# \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/g' /etc/sudoers
    sed -i 's/\# \%wheel ALL=(ALL) NOPASSWD: ALL/\%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

    #SETUP A VIDEOGRAPHIC DRIVER
    color cyan "What is your video graphic card?"
    select GPU in "Intel" "Nvidia" "Intel and Nvidia" "AMD";do
        case $GPU in
            "Intel")
                pacman -S --noconfirm xf86-video-intel -y
                break
            ;;
            "Nvidia")
                color cyan "Version of nvidia-driver to install"
                select NVIDIA in "GeForce-8 and newer" "GeForce-6/7" "Older";do
                    case $NVIDIA in
                        "GeForce-8 and newer")
                            pacman -S --noconfirm nvidia -y
                            break
                        ;;
                        "GeForce-6/7")
                            pacman -S --noconfirm nvidia-304xx -y
                            break
                        ;;
                        "Older")
                            pacman -S --noconfirm nvidia-340xx -y
                            break
                        ;;
                        *)
                            color red "Error ! Please input the correct num"
                        ;;
                    esac
                done
                break
            ;;
            "Intel and Nvidia")
                pacman -S --noconfirm bumblebee -y
                systemctl enable bumblebeed
                color cyan "Version of nvidia-driver to install"
                select NVIDIA in "GeForce-8 and newer" "GeForce-6/7" "Older";do
                    case $NVIDIA in
                        "GeForce-8 and newer")
                            pacman -S --noconfirm nvidia -y
                            break
                        ;;
                        "GeForce-6/7")
                            pacman -S --noconfirm nvidia-304xx -y
                            break
                        ;;
                        "Older")
                            pacman -S --noconfirm nvidia-340xx -y
                            break
                        ;;
                        *)
                            color red "Error ! Please input the correct num"
                        ;;
                    esac
                done
                break
            ;;
            "AMD")
                pacman -S --noconfirm xf86-video-ati -y
                break
            ;;
            *)
                color red "Error ! Please input the correct num"
            ;;
        esac
    done
	
}

postinstall(){
	color cyan "test"
	arch-chroot /mnt /bin/bash
	pacman -Syy
	pacman -Su
	pacman -S sudo
	sudo pacman -S xorg-server xorg-xinit xorg-apps mesa-libgl xterm
	color cyan "Install XFCE4? y/n"
    read xfce
    if [ "$xfce" == y ];then
    			pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
                lightdm_config
                gpasswd -a $USER lightdm
    			systemctl enable lightdm
    fi
     pacman -Sy
        pacman -S --noconfirm archlinuxcn-keyring
        pacman -S --noconfirm yaourt
    sudo pacman -S ttf-liberation ttf-dejavu opendesktop-fonts ttf-bitstream-vera ttf-arphic-ukai ttf-arphic-uming ttf-hanazono
    color green "Installation complete. Now run the command"
    color cyan "sudo systemctl reboot"
}

preinstall
install
sysconfig
postinstall

    

