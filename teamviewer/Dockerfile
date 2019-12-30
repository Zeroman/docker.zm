FROM zeroman/x11


RUN apt update && \
  apt install -y curl && \
  curl -fSL -o /tmp/teamviewer_linux.deb https://download.teamviewer.com/download/linux/teamviewer_amd64.deb && \
  apt -f -y install && \
  apt install -y libqt5gui5

RUN dpkg -i /tmp/teamviewer_linux.deb || echo "mierda" 
RUN apt update --fix-missing

RUN apt --fix-broken install -y
RUN apt-get install -y libqt5qml5

ENV DISPLAY :0.0
CMD teamviewer 
