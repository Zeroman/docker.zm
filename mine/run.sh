#!/bin/bash - 


# https://github.com/NVIDIA/nvidia-docker
# http://blog.csdn.net/smilingc/article/details/53760721
# https://github.com/CultClassik/nv-docker-equihash-ewbf
# https://hub.docker.com/u/cultclassik/

wallet=t1Y7Udc4sRAeNeML9CR1HeeUKVEHfRWZ9EN
pool_server=zec-cn1.dwarfpool.com
pool_port=3333
worker=zero_$RANDOM
# cn1-zcash.flypool.org

case $1 in
    r)
        docker run -d --name zcash kmdgeek/nheqminer /nheqminer -l $pool_server:$pool_port -u $wallet.$worker
        ;;
    rnv)
        # docker run --name zcash_nv --runtime=nvidia 
        sudo -b nohup nvidia-docker-plugin > /tmp/nvidia-docker.log
        nvidia-docker run --name zcash_nv \
            -e "NVIDIA_VISIBLE_DEVICES=1" -e "NVIDIA_DRIVER_CAPABILITIES=compute,utility" \
            -e "WORKER=$worker" \
            -e "T_ADDR=$wallet" \
            -e "INTENSITY=64" \
            -e "POOL_SERVER=$pool_server" \
            -e "POOL_PORT=$pool_port" \
            cultclassik/equihash-ewbf-nv
        ;;
    lnv)
        docker logs zcash_nv -f
        ;;
    l)
        docker logs zcash -f
        ;;
    c)
        docker kill zcash
        docker rm zcash
        ;;
    info)
        # firefox http://zcash.flypool.org/miners/t1Y7Udc4sRAeNeML9CR1HeeUKVEHfRWZ9EN
        firefox http://dwarfpool.com/zec/address?wallet=$wallet
        ;;
esac



