FROM debian:buster-slim

LABEL maintainer="alexis.jeandeau@gmail.com"

ARG lilypond_version="2.20.0"
ARG install_fonts="false"
ARG install_ly2video="false"

RUN apt-get update && apt-get install -y \
  # Required by the LilyPond installation script
  bzip2

WORKDIR /install

# Install LilyPond
ADD "https://lilypond.org/download/binaries/linux-64/lilypond-${lilypond_version}-1.linux-64.sh" ./
RUN chmod +x "lilypond-${lilypond_version}-1.linux-64.sh"
RUN "./lilypond-${lilypond_version}-1.linux-64.sh" --batch --prefix /lilypond

ENV PATH "/lilypond/bin:${PATH}"

# Install fonts for LilyPond
COPY install-lilypond-fonts.sh install-system-fonts.sh ./
RUN if [ "${install_fonts}" != "false" ]; then \
  apt-get install -y \
  fontconfig \
  # Required by install-lilypond-fonts.sh and install-system-fonts.sh
  wget \
  xz-utils \
  # System font installation through the repositories
  fonts-ipafont \
  fonts-ipaexfont \
  fonts-hanazono \
  fonts-noto-core \
  fonts-noto-cjk \
  # Manual system font installation (not in the repositories)
  && ./install-system-fonts.sh \
  # LilyPond font installation
  && ./install-lilypond-fonts.sh /lilypond/lilypond/usr/share/lilypond/current \
  && fc-cache -fv; fi

RUN if [ "${install_ly2video}" != "false" ]; then \
  apt-get install -y \
  git \
  ffmpeg \
  timidity \
  python-pip \
  python-pil \
  swig \
  libasound-dev \
  && git clone https://github.com/aspiers/ly2video.git \
  && cd ly2video && pip2 install -r requirements.txt && pip2 install .; fi

WORKDIR /app

RUN rm -rf /install /var/lib/apt/lists/*

CMD ["lilypond", "-v"]
