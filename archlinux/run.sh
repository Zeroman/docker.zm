#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

run_image()
{
    docker_opts=""
    docker_bind="" 

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:/root/.bashrc:ro"
    fi

    name=zm.archlinux-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v $cur_dir:/work \
            -w /work \
            zm.archlinux $@
    else
        docker start -i zm.archlinux
    fi
}

download_file()
{
    src=$1
    dst=$2
    md5=$3
    DL="wget -c"

    if [ -e "$dst" -a -n "$md5" ];then
        echo "$md5 $dst" | md5sum -c 
        if [ $? = 0 ];then
            return
        fi
    fi

    if false;then
        if which axel;then
            if [ ! -e "$2" ];then
                axel $1 -o $2
            fi
        else
            wget -c $1 -O $2
        fi
    else
        wget -O $2 $1 
    fi

    if [ -n "$md5" ];then
        echo "$md5 $dst" | md5sum -c 
    fi
}

init_archlinux()
{
    dl_dir=$PWD
    zm_arch='x86_64'
    src_url='http://mirrors.163.com'
    md5sum_file=$dl_dir/md5sums.txt
    download_file $src_url/archlinux/iso/latest/md5sums.txt $md5sum_file
    bootstrap_file=$(cat $md5sum_file | grep $zm_arch | awk '{print $2}')
    bootstrap_md5=$(cat $md5sum_file | grep $zm_arch | awk '{print $1}')
    download_file $src_url/archlinux/iso/latest/$bootstrap_file $bootstrap_file $bootstrap_md5
    tar xvf archlinux-bootstrap-2016.07.01-x86_64.tar.gz 
    tar czvf archlinux.tar.gz -C root.x86_64/ .
}

opt=$1
shift
case $opt in
    i|init)
        init_archlinux
        ;;
    b|build)
        docker build -t zm.archlinux .
        ;;
    bn|build_new)
        docker build -t zm.archlinux --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zm.archlinux
        docker rmi zm.archlinux
        ;;
    *)
        run_image $*
        ;;
esac

