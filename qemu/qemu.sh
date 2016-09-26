#!/bin/bash

cur_file_path=$(readlink -f $0)
cur_file_dir=${cur_file_path%/*}


share_sets=""
iso_sets=""
disk_sets=""
console_sets=""
bios_sets=""
floppy_img=""
sys_img=""
work_img=""
temp_img=""
sys_disk_type=""
work_disk_type=""
temp_disk_type=""
sd_img=""
create_img="no"
sd_img_size="4096M"
sys_img_size="64G"
work_img_size="64G"
temp_img_size="64G"
slic_name=""
daemonize=false
QEMU=qemu-system-x86_64

err()
{   
    echo "Error: $*"
    exit 1
}

check_udev()
{
    rules_file=/etc/udev/rules.d/99-color.rules
    if [ -e $rules_file ];then
        return
    fi
    echo 'ATTRS{idVendor}=="1782", ATTRS{idProduct}=="4d00", MODE="0660", GROUP="user"' > $rules_file
    sudo service udev reload
}

defalutConfig()
{
    vncPort=3389
    spicePort=5900
    spiceTitle="spice"
    clientSSHPort=""
    consolePort=""
    macaddr=""
    memSize=1536
    # usbIDs="1782:4d00 1782:3d00"
    usbIDs=""

    cpuCores=1
    cpuThreads=2

    diskIF=ide
    # diskIF=none
    # diskIF=scsi
    # diskIF=virtio
    net_dev_type=e1000 # ne2k_pci,i82551,i82557b,i82559er,rtl8139,e1000,pcnet,virtio

    extName=tmp
    extImgDir=""
    ext_temp_dir=""

    other_args=""

    net_dev="user"
    net_user_args=""
    net_tap_args=""
    net_bridge_args=""
}

genUsbDeviceSet()
{
    for dev in $usbIDs; do 
        echo -n "-usb -usbdevice host:$dev "
    done
}

createExtImg()
{
    baseImg=$1
    extImg=$2

    if [ ! -e $baseImg ];then
        echo "$baseImg is not exist!"
        exit 1
    fi

    if [ -e $extImg ];then
        echo "$extImg is exist!"
    else
        qemu-img create -f qcow2 -b $baseImg $extImg
    fi
}

getDiskImgFmt()
{
    if [ -e "$1" ];then
        qemu-img info $1 | grep -w format | awk '{print $3}'
    fi
}

start_bridge()
{
    local iface=$1
    local brname=$2
    local tapname=$3

    if ! brctl show | grep -w "$brname";then
        sudo brctl addbr $brname
    fi
    if ! ip tuntap show | grep -w "$tapname";then
        sudo ip tuntap add dev $tapname mode tap user $USER
    fi

    sudo brctl addif $brname $iface
    sudo brctl addif $brname $tapname

    local ipaddr=$(ip -f inet addr show dev $iface | sed -n 's/^ *inet *\([.0-9/]*\).*/\1/p')
    local gateway=$(ip route list | sed -n "s/^default via \([.0-9]*\) dev $iface.*/\1/p")

    sudo ip link set $brname up
    sudo ip link set $tapname up

    test -n "$ipaddr" && sudo ip addr replace $ipaddr dev $brname
    test -n "$gateway" && sudo ip route replace default via $gateway dev $brname
}

stop_bridge()
{
    local iface=$1
    local brname=$2
    local tapname=$3

    sudo ip link set $brname down
    sudo brctl delif $brname $tapname
    sudo brctl delif $brname $iface
    sudo ip tuntap del dev $tapname mode tap
    sudo brctl delbr $brname
}

use_bridge_net()
{
    local tapname=$1

    local -a phy_ifaces
    local index=0
    local options=""
    for face in $(ip link list up | sed -n 's/^[0-9]*: \(.*\):.*/\1/p')
    do
        if [ -e /sys/class/net/$face/device ];then
            phy_ifaces[$index]="$face"
            index=$(expr $index + 1)
            options+="$face $index.$face off "
        fi
    done

    if [ "$index" = 0 ];then
        err "no up phy eth devices"
    elif [ "$index" -gt 1 ];then
        local win_title="Select bridge network device" 
        local listtitle="Select one"
        sels=$(dialog --title "$win_title" --stdout --radiolist "$listtitle" 0 0 0 $options)
        if [ -z "$sels" ];then
            err "not select any phy eth devices"
        fi
        iface=$sels
    else
        iface=${phy_ifaces[0]}
    fi

    if [ -z "$tapname" ];then
        err "tap name is null"
    fi

    local brname=brkvm

    # $((RANDOM%256)) $((RANDOM%256))
    macaddr=$(printf 'DE:AD:BE:EF:%02X:%02X\n' $((0x$(sha1sum <<<$brname|cut -c1-2))) $((0x$(sha1sum <<<$tapname|cut -c1-2))))

    start_bridge $iface $brname $tapname

    net_dev="tap"
    net_tap_args="ifname=$tapname,script=no,downscript=no"
}

usage()
{
    echo "config:
    --vnc-port $vncPort
    --spice-port $spicePort
    --spice-title $spiceTitle
    --console-port $consolePort
    --macaddr $macaddr
    --mem-size $memSize
    --usb-ids $usbIDs
    --cpu-cores $cpuCores
    --cpu-threads $cpuThreads
    --disk-type $diskIF
    --net-type $net_dev_type
    --sys-img $sys_img
    --work-img $work_img
    --temp-img $temp_img
    --floppy-img $floppy_img
    --sys-disk-type $sys_disk_type
    --work-disk-type $work_disk_type
    --temp-disk-type $temp_disk_type
    --sd-img $sd_img
    --sd-size $sd_img_size
    --noaudio
    --boot-iso
    --with-iso test.iso
    --with-disk /dev/sdb
excute:
    --start-server-vnc
    --conncet-vnc
    --start-server-spice
    --conncet-spice
    --spice
    --compact-disk old new
    "
    exit 0
}

kvmConfig()
{
    argv=""
    while [ $# -gt 0 ]; do
        case $1 in
            --vnc-port) shift; vncPort=$1; shift;
                ;;
            --spice-port) shift; spicePort=$1; shift;
                ;;
            --spice-title) shift; spiceTitle=$1; shift;
                ;;
            --client-ssh-port) shift; clientSSHPort=$1; shift;
                ;;
            --console-port) shift; consolePort=$1; shift;
                ;;
            --macaddr) shift; macaddr=$1; shift;
                ;;
            --mem-size) shift; memSize=$1; shift;
                ;;
            --usb-ids) shift; usbIDs+="$1 "; shift;
                ;;
            --cpu-cores) shift; cpuCores=$1; shift;
                ;;
            --cpu-threads) shift; cpuThreads=$1; shift;
                ;;
            --disk-type) shift; diskIF=$1; shift;
                ;;
            --net-type) shift; net_dev_type=$1; shift;
                ;;
            --sys-img) shift; sys_img=$1; shift;
                ;;
            --work-img) shift; work_img=$1; shift;
                ;;
            --temp-img) shift; temp_img=$1; shift;
                ;;
            --floppy-img) shift; floppy_img=$1; shift;
                ;;
            --sys-disk-type) shift; sys_disk_type=$1; shift;
                ;;
            --work-disk-type) shift; work_disk_type=$1; shift;
                ;;
            --temp-disk-type) shift; temp_disk_type=$1; shift;
                ;;
            --sd-img) shift; sd_img=$1; shift;
                ;;
            --sd-size) shift; sd_img_size=$1; shift;
                ;;
            --ext-name) shift; extName=$1; shift;
                ;;
            --ext-img-dir) shift; extImgDir=$1; shift;
                ;;
            --ext-temp-dir) shift; ext_temp_dir=$1; shift;
                ;;
            --noaudio) export QEMU_AUDIO_DRV=none; shift;
                ;;
            --boot-iso) iso_sets+="-boot order=dc "; shift;
                ;;
            --with-iso) shift; iso_sets+="-drive file=$1,media=cdrom "; shift;
                ;;
            --with-disk) shift; disk_sets+="-drive file=$1,media=disk "; shift;
                ;;
            --with-slic) shift; slic_name="$1"; shift;
                ;;
            --create-img) create_img="yes";shift;
                ;;
            -d|--daemonize) shift; daemonize=true;
                ;;
            --append) shift; other_args="$1"; shift;
                ;;
            --net-dev) shift; net_dev="$1"; shift
                ;;
            --net-user-args) shift; net_user_args="$1"; shift
                ;;
            --net-tap-args) shift; net_tap_args="$1"; shift
                ;;
            --net-bridge-args) shift; net_bridge_args="$1"; shift
                ;;
            --use-bridge) shift; use_bridge_net $1; shift
                ;;
            *) argv+="$1 "; shift; 
                ;;
      esac
  done 
}

create_qemu_img()
{
    local imgname="$1"
    local imgpath="$2"
    local imgsize="$3"

    if [ -z "$imgpath" ];then
        echo "$imgname path is null"
        return
    fi

    if [ ! -e "$imgpath" ];then
        if [ $create_img = "no" ];then
            err "No $imgname img file : $imgpath"
        fi
        qemu-img create -f qcow2 $imgpath $imgsize
    fi
}

initConfig()
{
    create_qemu_img sys "$sys_img" "$sys_img_size"
    create_qemu_img work "$work_img" "$work_img_size"
    create_qemu_img temp "$temp_img" "$temp_img_size"

    if [ -n "$extImgDir" ];then
        mkdir -p "$extImgDir"

        fmt=$(getDiskImgFmt $sys_img)
        if [ "$fmt" = "qcow2" ];then
            baseimg=$(readlink -f $sys_img)
            sys_img=$extImgDir/$(basename $sys_img).$extName
            createExtImg $baseimg $sys_img
        fi

        fmt=$(getDiskImgFmt $work_img)
        if [ "$fmt" = "qcow2" ];then
            baseimg=$(readlink -f $work_img)
            work_img=$extImgDir/$(basename $work_img).$extName
            createExtImg $baseimg $work_img
        fi

        fmt=$(getDiskImgFmt $temp_img)
        if [ "$fmt" = "qcow2" ];then
            if [ -z "$ext_temp_dir" ];then
                ext_temp_dir=$extImgDir
            fi
            mkdir -p $ext_temp_dir
            baseimg=$(readlink -f $temp_img)
            temp_img=$ext_temp_dir/$(basename $temp_img).$extName
            createExtImg $baseimg $temp_img
        fi
    fi

    # -usbdevice disk:format=raw:/virt/usb_disk.raw
    # telnet localhost $consolePort ;
    # (qemu) drive_add 0 id=my_usb_disk,if=none,file=udisk.img
    # (qemu) device_add usb-storage,id=my_usb_disk,drive=my_usb_disk,removable=on
    # (qemu) device_del my_usb_disk

    test -z "$sys_disk_type" && sys_disk_type="$diskIF"
    test -z "$work_disk_type" && work_disk_type="$diskIF"
    test -z "$temp_disk_type" && temp_disk_type="$diskIF"
    vnc_sets="-vnc 127.0.0.1:0 -redir tcp:$vncPort::$vncPort"
    usb_sets="-usb -usbdevice tablet $(genUsbDeviceSet)"
    test -e "$sys_img" && disk_sets+=" -drive file=${sys_img},if=$sys_disk_type,cache=writeback"
    test -e "$temp_img" && disk_sets+=" -drive file=${temp_img},if=$temp_disk_type,cache=writeback"
    test -e "$work_img" && disk_sets+=" -drive file=${work_img},if=$work_disk_type,cache=writeback"
    test -e "$floppy_img" && disk_sets+=" -fda ${floppy_img}"
    # -cpu kvm64 -M pc 
    base_sets="-localtime -cpu host -smp cores=$cpuCores,threads=$cpuThreads -soundhw hda -m $memSize -enable-kvm"
    if $daemonize;then
        base_sets+=" --daemonize"
    fi

    if [ -z "$macaddr" ];then
        macaddr=08:00:27:23:35:32
        if [ -n "$sys_img" -a -n "$work_img" ];then
            macaddr=$(printf 'DE:AD:BE:EF:%02X:%02X\n' $((0x$(sha1sum <<<$sys_img|cut -c1-2))) $((0x$(sha1sum <<<$work_img|cut -c1-2))))
        fi
    fi
    net_sets=" -device $net_dev_type,netdev=net.$net_dev.0"
    case $net_dev in
        user)
            net_sets+=" -netdev user,id=net.$net_dev.0,ipv6=off"
            test -n "$net_user_args" && net_sets+=",$net_user_args"
            ;;
        tap)
            net_sets+=" -netdev tap,id=net.$net_dev.0"
            test -n "$net_tap_args" && net_sets+=",$net_tap_args"
            ;;
        bridge)
            net_sets+=" -netdev bridge,id=net.$net_dev.0"
            test -n "$net_bridge_args" && net_sets+=",$net_bridge_args"
            ;;
        *)
            ;;
    esac

    if [ -n "$consolePort" ];then
        console_sets="-monitor telnet::$consolePort,server,nowait"
    fi
    if [ -n "$clientSSHPort" ];then
        net_sets+=" -redir tcp:$clientSSHPort::22"
    fi
    if [ -e "/usr/share/doc/qemu-system-common/ich9-ehci-uhci.cfg" ];then
        ich9_cfg_path=/usr/share/doc/qemu-system-common/ich9-ehci-uhci.cfg
    else
        ich9_cfg_path=$cur_file_dir/ich9-ehci-uhci.cfg
    fi

    spice_sets="-vga qxl -spice port=$spicePort,agent-mouse=on,disable-ticketing"
    # for agent copy and paste
    spice_sets+=" -device virtio-serial -chardev spicevmc,id=vdagent,debug=0,name=vdagent"
    spice_sets+=" -device virtserialport,chardev=vdagent,name=com.redhat.spice.0"
    # for usb redirection
    spice_sets+=" -device ich9-usb-ehci1,id=usb 
    -device ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on 
    -device ich9-usb-uhci2,masterbus=usb.0,firstport=2 
    -device ich9-usb-uhci3,masterbus=usb.0,firstport=4 
    -chardev spicevmc,name=usbredir,id=usbredirchardev1 
    -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 
    -chardev spicevmc,name=usbredir,id=usbredirchardev2 
    -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 
    -chardev spicevmc,name=usbredir,id=usbredirchardev3 
    -device usb-redir,chardev=usbredirchardev3,id=usbredirdev3"
    # for CAC smartcard redirection, spicy:--spice-smartcard
    # spice_sets+=" -device usb-ccid -chardev spicevmc,name=smartcard -device ccid-card-passthru,chardev=ccid"
    # Multiple monitor support
    # spice_sets+=" -vga qxl -device qxl"

    #for share dir
    # spice_sets+=" -device virtserialport,chardev=charchannel1,id=channel1,name=org.spice-space.webdav.0 
    # -chardev spiceport,name=org.spice-space.webdav.0,id=charchannel1"

    if [ -n "$sd_img" ];then
        if [ ! -e "$sd_img" ];then
            qemu-img create -f raw $sd_img $sd_img_size
        fi
        disk_sets+=" -usb -drive if=none,file=$sd_img,cache=writeback,id=udisk -device usb-storage,drive=udisk,removable=on"
    fi
    # macaddr=88:88:88:88:88:88
    # base_sets="-localtime -cpu kvm32 -smp cpus=8 -soundhw es1370 -m 2048 -usbdevice tablet -vga vmware"
    # net_sets="-net nic,model=virtio,macaddr=$macaddr -net user,smb=/work/com/color/,smbserver=10.0.2.8"
    # share_sets="-virtfs local,path=/work/com/color/,mount_tag=color,readonly"

    if [ -n "$slic_name" ];then
        bios_bin=$cur_file_dir/bios.bin
        slic_bin=$cur_file_dir/${slic_name}.bin
        echo $bios_bin $slic_bin
        if [ -e "$bios_bin" -a -e "$slic_bin" ];then
            bios_sets="--bios $bios_bin --acpitable file=$slic_bin"
        fi
    fi

    common_sets=$(echo $base_sets $console_sets $net_sets $usb_sets $share_sets $disk_sets $iso_sets $bios_sets $other_args)
    echo "--------------------------------------"
    echo $common_sets
    echo "--------------------------------------"
}

kvm_uninit()
{
    echo "kvm uninit"
}

kvmExcute()
{
    trap kvm_uninit ERR INT TERM EXIT

    spice_client='spicy --spice-disable-effects=wallpaper,animation'
    #spice_client='spicy --spice-color-depth=16 --spice-disable-effects=wallpaper,animation'
    case $1 in
        --start-server-vnc)
            $QEMU $common_sets $vnc_sets
            ;;
        --connect-vnc)
            rdesktop 127.0.0.1:$vncPort -g 1024x768 -u root -p root -D -P -K -r sound:local -r clipboard:PRIMARYCLIPBOARD
            # rdesktop localhost:$vncPort -x 0x80 -u root -p root -f -D -z -P -r sound:local -clipboard # for win7
            ;;
        --start-server-spice)
            $QEMU $common_sets $spice_sets
            ;;
        --conncet-spice)
            # spicec -h 127.0.0.1 -p $spicePort
            $spice_client -h 127.0.0.1 -p $spicePort --title "$spiceTitle"
            ;;
        --spice)
            shift
	    echo $spice_sets
            $QEMU $common_sets $spice_sets $@
            # sleep 3
            # $spice_client -f -h 127.0.0.1 -p $spicePort --title "$spiceTitle"
            ;;
        --local)
            $QEMU $common_sets -vga virtio
            ;;
        --compact-disk)
            if [ -e $2 ];then
                file $2
                qemu-img convert -c -O qcow2 $2 $3
            fi
            ;;
        --commit-disk)
            if [ -e $2 ];then
                file $2
                qemu-img commit -f qcow2 $2
                \rm -i $2
            fi
            ;;
        --create-base-disk)
            if [ ! -e $2 ];then
                qemu-img create -f qcow2 $2 $3
            fi
            ;;
        --create-ext-disk) createExtImg $2 $3
            ;;
        *)
            ;;
    esac
}

defalutConfig
test $# = 0 && usage
kvmConfig "$@"
initConfig
kvmExcute $argv
