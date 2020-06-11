FROM ubuntu:18.04
ENV THEOS /opt/theos
ENV PATH "$THEOS/bin:$PATH"
COPY setup.sh .
RUN ./setup.sh
