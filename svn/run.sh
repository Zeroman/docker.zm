#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

run_image()
{
    docker_opts=""
    docker_bind="" 

    name=zeroman.svn-$(basename $cur_dir)

    docker_opts+=" -it --rm -p 3690:3690 --name $name"

    repo_dir=$cur_dir/svn_repo
    docker_bind+="-v $repo_dir:/svn"

    # -e 's/# authz-db/authz-db/g' \

    if [ ! -e "$repo_dir/conf/svnserve.conf" ];then
        mkdir -p $repo_dir
        docker run $docker_opts $docker_bind zeroman/svn svnadmin create /svn
        docker run $docker_opts $docker_bind zeroman/svn sed -i \
            -e 's/# auth-access/auth-access/g' \
            -e 's/# password-db/password-db/g' \
            -e 's/# anon-access/anon-access/g' \
            /svn/conf/svnserve.conf
        docker run $docker_opts $docker_bind zeroman/svn sed -i \
            -e '/^\[users\]/a test = test' /svn/conf/passwd
    fi

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        echo "start server ..."
        docker run $docker_opts $docker_bind zeroman/svn 
    else
        docker start -it $name
    fi
}

test_svn()
{
    mkdir -p test_prj/{trunk/src,branches,tags}
    echo '/*test source*/' > test_prj/trunk/src/test.c
    svn import test_prj svn://localhost/test_prj/ -m 'base test prj' --username test --password test
    svn ls svn://localhost/
    test_branch
    svn co svn://localhost/ svn_local
}

test_branch()
{
    prj=svn://localhost/test_prj
    svn copy $prj/trunk $prj/branches/src1.0 -m 'create branch for src 1.0'
    svn copy $prj/trunk $prj/branches/src2.0 -m 'create branch for src 2.0'
    svn copy $prj/trunk $prj/branches/src3.0 -m 'create branch for src 3.0'

    # cd svn_local/test_prj/branches/src1.0
    # modify and commit more times
    # cd svn_local/test_prj/branches/src2.0
    # svn mergeinfo $prj/branches/src1.0
    # svn merge $prj/branches/src1.0
    # svn commit . -m 'merge'
    # svn log -gv
}
 

opt=$1
shift
case $opt in
    b|build)
        docker build -t zeroman/svn .
        ;;
    bn|build_new)
        docker build -t zeroman/svn --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    show)
        svn ls svn://localhost/ 
        # svn ls svn://localhost/ --username test --password test
        ;;
    test)
        test_svn
        ;;
    c|clean)
        # docker rm zeroman/svn
        # docker rmi zeroman/svn
        sudo rm -rf svn_repo
        sudo rm -rf svn_local
        sudo rm -rf test_prj
        ;;
    *)
        run_image $*
        ;;
esac

