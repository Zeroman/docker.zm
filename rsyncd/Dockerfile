FROM zeroman/base

COPY rsyncd.* /etc/

VOLUME /share

EXPOSE 873 

CMD rsync --daemon --no-detach -vv --log-file /dev/stdout


