#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


run_image()
{
    docker_opts=""
    docker_bind="" 
    contain_params=""

    hostdev=false

    for arg in $*
    do
        if [ "$arg" == "nfs" ];then
            if ! modprobe nfsd nfsv2 nfsv3 nfsv4;then
                sudo modprobe nfsd nfsv2 nfsv3 nfsv4
                sudo mount -t nfsd nfsd /proc/fs/nfsd
            fi
            mkdir -p $cur_dir/nfs
            docker_bind+="-v $cur_dir/nfs:/nfs"
            contain_params+="$arg "
            hostdev=true
        elif [ "$arg" == "tftp" ];then
            mkdir -p $cur_dir/tftp
            docker_bind+=" -v $cur_dir/tftp:/srv/tftp"
            contain_params+="$arg "
        elif [ $(expr match "$arg" ".*:.*") -ne 0 ];then
            usbs=$(lsusb | grep $arg)
            if [ -n "$usbs" ];then
                bus=$(echo $usbs | awk '{print $2}')
                id=$(echo $usbs | awk '{print $4}')
                docker_opts+=" --device=/dev/bus/usb/$bus/${id::-1}"
            fi
        elif [ $(expr match "$arg" "tty.*") -ne 0 ];then
            if [ -e "/dev/$arg" ];then
                docker_opts+=" --device=/dev/$arg"
            fi
        else
            contain_params+="$arg "
        fi
    done

    if $hostdev;then
        docker_opts+=" --privileged"
    fi

    if [ -e $HOME/.kermrc ];then
        docker_bind+=" -v $HOME/.kermrc:/home/developer/.kermrc:ro"
    fi
    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:/home/developer/.bashrc:ro"
    fi

    for rule in "*.rules"
    do
        if [ -e $rule ];then
            docker_bind+=" -v $PWD/$rule:/etc/udev/rules.d/$rule:ro"
        fi
    done

    name=zm.cross_develop-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v $cur_dir:/work \
            -e UID=$UID \
            -w /work \
            zm.cross_develop $contain_params
    else
        # docker start -i $name
        docker exec -it $name bash
    fi
}

test_image()
{
    if [ ! -e /nfs/$cur_filename ];then
        sudo cp -fv $cur_path $cur_dir/nfs/
        return
    fi

    echo "test nfs kernel server."
    touch /nfs/test_nfs
    mount -v -t nfs -o nolock localhost:/ /mnt
    ls -l /mnt/
    rm -fv /nfs/test_nfs
    ls -l /mnt/
    umount /mnt

    echo "test tftpd-hpa."
    echo "test file" > /srv/tftp/test_file
    cd /tmp/
    tftp 127.0.0.1 -c get test_file
    md5sum /srv/tftp/test_file test_file
}


opt=$1
shift
case $opt in
    b|build)
        docker build -t zm.cross_develop .
        ;;
    bn|build_new)
        docker build -t zm.cross_develop --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    t|test)
        test_image
        ;;
    c|clean)
        rmdir nfs
        rmdir tftp
        docker rm zm.cross_develop
        docker rmi zm.cross_develop
        ;;
    *)
        run_image $*
        ;;
esac


