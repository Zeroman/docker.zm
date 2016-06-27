#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


run_image()
{
    docker_opts=""
    docker_bind="" 

    name=zm.wine-$(basename $cur_dir)

    docker_bind+="-v $PWD/.wine:/root/.wine" 

    hostdev=true
    if $hostdev;then
        docker_opts+=" --privileged"
    fi

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:/root/.bashrc:ro"
    fi

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        # xhost +
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
            -v $cur_dir:/work \
            -e UID=$UID \
            -w /work \
            zm.wine $@
    else
        docker start -i $name
    fi
}

wine_zhcn_font()
{
    WINE=wine-development
    fonts_dir=$cur_dir/.wine/drive_c/windows/Fonts
    system_reg=$cur_dir/.wine/system.reg
    font_path=$cur_workdir/simsun.ttc
    font_reg=$cur_workdir/zhcn_font.reg
    if [ -d $fonts_dir -a -e $font_path -a -e $font_reg ];then
        # sudo cp -fv  $font_path $fonts_dir/
        sudo cp -fv *.ttf *.ttc $fonts_dir/
        sed -i 's/LogPixels"=dword:00000060/LogPixels"=dword:00000070/g'    $system_reg
        sed -i 's/MS Shell Dlg"="Tahoma/MS Shell Dlg"="SimSun/g'            $system_reg
        sed -i 's/MS Shell Dlg 2"="Tahoma/MS Shell Dlg 2"="SimSun/g'        $system_reg
        sudo cp -fv $font_reg $cur_dir/.wine/drive_c/
        run_image $WINE regedit /s c:\\zhcn_font.reg
    fi
}


opt=$1
shift
case $opt in
    b|build)
        docker build -t zm.wine .
        ;;
    bn|build_new)
        docker build -t zm.wine --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zm.wine-$(basename $cur_dir)
        ;;
    ci|clean_image)
        docker rmi zm.wine
        ;;
    cn|chinese_font)
        wine_zhcn_font
        ;;
    *)
        run_image $*
        ;;
esac


