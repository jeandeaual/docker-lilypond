FROM debian:buster-slim

LABEL maintainer="alexis.jeandeau@gmail.com"

ARG lilypond_version="2.20.0"

RUN apt-get update && apt-get install -y \
  # LilyPond install script dependency
  bzip2 \
  # ly2video dependencies
  git \
  ffmpeg \
  timidity \
  python-pip \
  python-pil \
  swig \
  libasound-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /install

# Install LilyPond
ADD "https://lilypond.org/download/binaries/linux-64/lilypond-${lilypond_version}-1.linux-64.sh" ./
RUN chmod +x "lilypond-${lilypond_version}-1.linux-64.sh"
RUN "./lilypond-${lilypond_version}-1.linux-64.sh" --batch --prefix /lilypond

# Install ly2video
RUN git clone https://github.com/aspiers/ly2video.git
RUN cd ly2video && pip2 install -r requirements.txt && pip2 install .

WORKDIR /app

RUN rm -rf /install

ENV PATH "/lilypond/bin:${PATH}"

CMD ["lilypond", "-dno-point-and-click"]
