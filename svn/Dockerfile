FROM zeroman/base

RUN apt-get install -y --no-install-recommends subversion

EXPOSE 3690 

CMD /usr/bin/svnserve -d --foreground -r /svn
