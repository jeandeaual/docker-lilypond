# ARGs used in FROM need to be declared before the first FROM
# See https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG suffix=""
ARG lilypond_version="2.22.0"

FROM debian:bullseye-slim AS build

SHELL ["/bin/bash", "-c"]

RUN printf 'LANG="C"\nLANGUAGE="C"\nLC_ALL="C"\n' > /etc/default/locale

RUN echo "deb-src http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list

RUN source /etc/default/locale \
  && apt-get update \
  # Install the LilyPond build dependencies
  && apt-get build-dep -y lilypond \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    # To get newer config.sub and config.guess
    autotools-dev \
    # LilyPond build dependencies
    git \
    guile-2.2-dev \
    install-info \
    python3 \
    python-is-python3

WORKDIR /build

ARG lilypond_version

# Install LilyPond
RUN git clone --no-tags --single-branch --depth 1 --branch "release/${lilypond_version}-1" https://git.savannah.gnu.org/git/lilypond.git

WORKDIR /build/lilypond

RUN ./autogen.sh --noconfigure \
  # Update the configure script (required to build on arm64)
  && cp /usr/share/misc/config.{sub,guess} ./config/ \
  && mkdir build

WORKDIR /build/lilypond/build

RUN mkdir /lilypond \
  && ../configure --prefix /lilypond --disable-debugging --disable-documentation \
  && make -j$(cat /sys/fs/cgroup/cpuset/cpuset.cpus | cut -d- -f 2) \
  && make install

FROM debian:bullseye-slim AS lilypond

SHELL ["/bin/bash", "-c"]

RUN printf 'LANG="C"\nLANGUAGE="C"\nLC_ALL="C"\n' > /etc/default/locale

RUN source /etc/default/locale \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    # LilyPond run dependencies
    libglib2.0-0 \
    guile-2.2 \
    libpangoft2-1.0-0 \
    fontconfig \
    fonts-dejavu \
    ghostscript \
    # LilyPond optional dependencies
    extractpdfmark \
    # To transform PDFs (e.g. rotate)
    qpdf

COPY --from=build /lilypond /lilypond

ENV PATH "/lilypond/bin:${PATH}"

# Image with the fonts
FROM lilypond AS lilypond-fonts

SHELL ["/bin/bash", "-c"]

COPY install-lilypond-fonts.sh install-system-fonts.sh ./

ARG lilypond_version

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
  && ./install-lilypond-fonts.sh "/lilypond/share/lilypond/${lilypond_version}" \
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
  fluid-soundfont-gm \
  fluid-soundfont-gs \
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
  fluid-soundfont-gm \
  fluid-soundfont-gs \
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
RUN apt-get remove -y bzip2 wget xz-utils build-essential python3-dev libasound-dev libjpeg-dev zlib1g-dev \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

CMD ["lilypond", "-v"]
