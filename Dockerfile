# ARGs used in FROM need to be declared before the first FROM
# See https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG suffix=""

FROM debian:bullseye-slim AS lilypond

SHELL ["/bin/bash", "-c"]

RUN printf 'LANG="C"\nLANGUAGE="C"\nLC_ALL="C"\n' > /etc/default/locale

RUN source /etc/default/locale \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    locales \
    make \
    qpdf \
    # Required by the LilyPond installation script
    bzip2

WORKDIR /install

ARG lilypond_version="2.22.0"

# Install LilyPond
ADD "https://lilypond.org/download/binaries/linux-64/lilypond-${lilypond_version}-1.linux-64.sh" ./
RUN chmod +x "lilypond-${lilypond_version}-1.linux-64.sh"
RUN "./lilypond-${lilypond_version}-1.linux-64.sh" --batch --prefix /lilypond

ENV PATH "/lilypond/bin:${PATH}"

# Image with the fonts
FROM lilypond AS lilypond-fonts

SHELL ["/bin/bash", "-c"]

COPY install-lilypond-fonts.sh install-system-fonts.sh ./

# Install fonts for LilyPond
RUN apt-get install -y --no-install-recommends \
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
  && fc-cache -fv

# Image with ly2video
FROM lilypond AS lilypond-ly2video

SHELL ["/bin/bash", "-c"]

COPY install-ly2video.sh ./

# Install ly2video
RUN apt-get install -y --no-install-recommends \
  git \
  # Required by ly2video
  ffmpeg \
  timidity \
  build-essential \
  python3-pip \
  python3-pil \
  python3-dev \
  swig \
  libasound-dev \
  # Required by Pillow
  libjpeg-dev \
  zlib1g-dev \
  && ./install-ly2video.sh

# Image with both the fonts and ly2video
FROM lilypond-fonts AS lilypond-fonts-ly2video

COPY install-ly2video.sh ./

# Install ly2video
RUN apt-get install -y --no-install-recommends \
  git \
  # Required by ly2video
  ffmpeg \
  timidity \
  build-essential \
  python3-pip \
  python3-pil \
  python3-dev \
  swig \
  libasound-dev \
  # Required by Pillow
  libjpeg-dev \
  zlib1g-dev \
  && ./install-ly2video.sh

# Final image
FROM lilypond${suffix} AS final

LABEL maintainer="alexis.jeandeau@gmail.com"

# Cleanup
RUN rm -rf /install /var/lib/apt/lists/*

WORKDIR /app

CMD ["lilypond", "-v"]
