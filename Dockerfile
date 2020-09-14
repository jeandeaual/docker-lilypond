FROM debian:buster-slim

LABEL maintainer="alexis.jeandeau@gmail.com"

ARG lilypond_version="2.20.0"
ARG ly2video="false"

RUN apt-get update && apt-get install -y \
  bzip2 \
  wget \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /install

# Install LilyPond
ADD "https://lilypond.org/download/binaries/linux-64/lilypond-${lilypond_version}-1.linux-64.sh" ./
RUN chmod +x "lilypond-${lilypond_version}-1.linux-64.sh"
RUN "./lilypond-${lilypond_version}-1.linux-64.sh" --batch --prefix /lilypond

ENV PATH "/lilypond/bin:${PATH}"

# Install fonts for LilyPond
COPY install-fonts.sh ./
RUN ./install-fonts.sh

RUN if [ "${ly2video}" != "false" ]; then \
  apt-get update && apt-get install -y \
  git \
  ffmpeg \
  timidity \
  python-pip \
  python-pil \
  swig \
  libasound-dev \
  && rm -rf /var/lib/apt/lists/* \
  && git clone https://github.com/aspiers/ly2video.git \
  && cd ly2video && pip2 install -r requirements.txt && pip2 install .; fi

WORKDIR /app

RUN rm -rf /install

CMD ["lilypond", "-v"]
