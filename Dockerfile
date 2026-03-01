#syntax=docker/dockerfile:1
FROM alpine:3.18

RUN apk add --update --no-cache gcc \
    g++ \
    make \
    libevent libevent-dev \
    zlib zlib-dev \
    openssl openssl-dev \
    wget \
    python3 \
    py3-pip

RUN mkdir /build

WORKDIR /build

RUN wget -O tor.tar.gz https://dist.torproject.org/tor-0.4.8.3-rc.tar.gz && \
    tar xzf tor.tar.gz 

WORKDIR /build/tor-0.4.8.3-rc

RUN ./configure && make install

RUN rm -rf /build && \
    apk del gcc g++ make libevent-dev zlib-dev openssl-dev wget

WORKDIR /

COPY ./requirements.txt .
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

COPY ./start-tor.sh .
COPY ./entrypoint.sh .
COPY ./healthcheck.py .

RUN chmod +x /start-tor.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
