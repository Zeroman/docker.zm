#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

run_mono_studio()
{
    docker_opts=""
    docker_bind="" 

    name="mono_studio_$(basename $cur_dir)"

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
            zeroman/mono 
    else
        docker start -i $name
    fi
}

run_gradle_image()
{
    docker_opts=""
    docker_bind="" 

    # docker_opts+=" --privileged"

    name="mono_gradle_$(basename $cur_dir)"

    gradle_home="$cur_dir/.gradle"
    if [ -e "$HOME/.gradle" ];then
        gradle_home=$(readlink -e "$HOME/.gradle")
    fi
    docker_bind+=" -v $gradle_home:/home/developer/.gradle"
    echo --- $docker_bind

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:/home/developer/.bashrc:ro"
    fi

    echo 'sudo update-alternatives --set mono /usr/lib/jvm/mono-8-openjdk-amd64/jre/bin/mono'
    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v /work/mono:/work/mono \
            -v $cur_dir:/work/src \
            -e UID=$UID \
            -w /work/src \
            zeroman/mono $@
    else
        docker start -i $name
    fi
}

test_image()
{
    echo "test now" 
    name="mono_gradle_$(basename $cur_dir)"
    docker run -it --rm --name $name zeroman/mono /bin/bash
}

download_mono_studio()
{
    ver='2.1.2.0'
    filever='143.2915827'
    filename=mono-studio-ide-${filever}-linux.zip
    sha1sum='d34c75ae2ca1cf472e21eb5301f43603082c6fd0'
    if ! echo "$sha1sum $filename" | sha1sum -c ;then
        wget -c https://dl.google.com/dl/mono/studio/ide-zips/${ver}/${filename} -O ${filename}
    fi
    ln -sfv ${filename} mono-studio-ide-linux.zip 
}


opt=$1
shift
case $opt in
    download)
        download_mono_studio
        ;;
    b|build)
        docker build -t zeroman/mono .
        ;;
    bn|build_new)
        docker build -t zeroman/mono --no-cache .
        ;;
    md|mono_studio)
        run_mono_studio
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
        docker rm zeroman/mono
        docker rmi zeroman/mono
        ;;
    *)
        docker run -it --rm zeroman/mono $@
        ;;
esac

