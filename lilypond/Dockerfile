FROM debian:buster-slim

LABEL maintainer="alexis.jeandeau@gmail.com"

ARG lilypond_version="2.20.0"

RUN apt-get update && apt-get install -y \
  # LilyPond install script dependency
  bzip2 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /install

# Install LilyPond
ADD "https://lilypond.org/download/binaries/linux-64/lilypond-${lilypond_version}-1.linux-64.sh" ./
RUN chmod +x "lilypond-${lilypond_version}-1.linux-64.sh"
RUN "./lilypond-${lilypond_version}-1.linux-64.sh" --batch --prefix /lilypond

WORKDIR /app

RUN rm -rf /install

ENV PATH "/lilypond/bin:${PATH}"

CMD ["lilypond", "-dno-point-and-click"]
