#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

run_android_studio()
{
    docker_opts=""
    docker_bind="" 

    for rule in $(ls *.rules)
    do
        docker_bind+=" -v $PWD/$rule:/etc/udev/rules.d/$rule:ro"
    done

    gradle_home="$cur_dir/.gradle"
    if [ -e "$HOME/.gradle" ];then
        gradle_home=$(readlink -e "$HOME/.gradle")
    fi
    docker_bind+=" -v $gradle_home:/home/developer/.gradle"

    AndroidStudioVer=2.1
    AndroidStudioCfgDir=$cur_dir/.AndroidStudio${AndroidStudioVer}
    mkdir -p "$AndroidStudioCfgDir"
    cfg_dir=$(basename $AndroidStudioCfgDir)
    docker_bind+=" -v $AndroidStudioCfgDir:/home/developer/$cfg_dir"

    AndroidDir=$cur_dir/.android
    if [ -e "$HOME/.android" ];then
        AndroidDir=$(readlink -e "$HOME/.android")
    fi
    mkdir -p $AndroidDir
    cfg_dir=$(basename $AndroidDir)
    docker_bind+=" -v $AndroidDir:/home/developer/$cfg_dir"

    for rule in "*.rules"
    do
        if [ -e $rule ];then
            docker_bind+=" -v $PWD/$rule:/etc/udev/rules.d/$rule:ro"
        fi
    done

    if [ ! -d "android-studio" ];then
        echo "no dir android-studio"
        return
    fi

    name="android_studio_$(basename $cur_dir)"

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --rm --name $name --privileged --net=host $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
            -v $cur_dir:/work \
            -e UID=$UID \
            -w /work \
            zeroman/android /work/android-studio/bin/studio.sh
    else
        docker start -i $name
    fi
}

run_gradle_image()
{
    docker_opts=""
    docker_bind="" 

    # docker_opts+=" --privileged"

    name="android_gradle_$(basename $cur_dir)"

    gradle_home="$cur_dir/.gradle"
    if [ -e "$HOME/.gradle" ];then
        gradle_home=$(readlink -e "$HOME/.gradle")
    fi
    docker_bind+=" -v $gradle_home:/home/developer/.gradle"
    echo --- $docker_bind

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:/home/developer/.bashrc:ro"
    fi

    echo 'sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java'
    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v /work/android:/work/android \
            -v $cur_dir:/work/src \
            -e UID=$UID \
            -w /work/src \
            zeroman/android $@
    else
        docker start -i $name
    fi
}

test_image()
{
    echo "test now" 
    name="android_gradle_$(basename $cur_dir)"
    docker run -it --rm --privileged --name $name zeroman/android /bin/bash
}

download_android_studio()
{
    ver='2.1.2.0'
    filever='143.2915827'
    filename=android-studio-ide-${filever}-linux.zip
    sha1sum='d34c75ae2ca1cf472e21eb5301f43603082c6fd0'
    if ! echo "$sha1sum $filename" | sha1sum -c ;then
        wget -c https://dl.google.com/dl/android/studio/ide-zips/${ver}/${filename} -O ${filename}
    fi
    if [ ! -e android-studio.tar ];then
        unzip ${filename}
        tar cvf android-studio.tar android-studio
    fi
    # ln -sfv ${filename} android-studio-ide-linux.zip 
}


opt=$1
shift
case $opt in
    download)
        download_android_studio
        ;;
    b|build)
        docker build -t zeroman/android .
        ;;
    bn|build_new)
        docker build -t zeroman/android --no-cache .
        ;;
    as|android_studio)
        run_android_studio
        ;;
    r|run)
        test_image $@
        ;;
    shell)
        run_image /bin/bash
        ;;
    t|test)
        test_image
        ;;
    g|gradle)
        run_gradle_image
        ;;
    c|clean)
        docker rm zeroman/android
        docker rmi zeroman/android
        ;;
    *)
        docker run -it --rm zeroman/android $@
        ;;
esac

