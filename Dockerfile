# ARGs used in FROM need to be declared before the first FROM
# See https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG suffix=""
ARG lilypond_version="2.22.0"
ARG username=lilypond
ARG user_uid=1000
ARG user_gid=$user_uid



FROM debian:bullseye-slim AS build

RUN printf 'LANG="C"\nLANGUAGE="C"\nLC_ALL="C"\n' > /etc/default/locale \
  && . /etc/default/locale \
  && echo "deb-src http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list \
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
    python-is-python3

WORKDIR /build

ARG lilypond_version

# Install LilyPond
RUN git clone --no-tags --single-branch --branch "release/${lilypond_version}-1" https://git.savannah.gnu.org/git/lilypond.git

WORKDIR /build/lilypond

RUN ./autogen.sh --noconfigure \
  # Update the configure script (required to build on arm64)
  && cp /usr/share/misc/config.sub /usr/share/misc/config.guess ./config/ \
  && mkdir build

WORKDIR /build/lilypond/build

RUN mkdir /lilypond \
  && ../configure --prefix /lilypond --disable-debugging --disable-documentation \
  && make -j"$(cut -d- -f 2 /sys/fs/cgroup/cpuset/cpuset.cpus)" \
  && make install



FROM debian:bullseye-slim AS lilypond

# hadolint ignore=DL3009
RUN printf 'LANG="C"\nLANGUAGE="C"\nLC_ALL="C"\n' > /etc/default/locale \
  && . /etc/default/locale \
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
    # For convert-ly
    python-is-python3 \
    # LilyPond optional dependencies
    extractpdfmark \
    # To transform PDFs (e.g. rotate)
    qpdf

COPY --from=build /lilypond /lilypond

ENV PATH "/lilypond/bin:${PATH}"



# Image with the fonts
FROM lilypond AS lilypond-fonts

COPY install-lilypond-fonts.sh install-system-fonts.sh /tmp/

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
  && /tmp/install-system-fonts.sh \
  # LilyPond font installation
  && /tmp/install-lilypond-fonts.sh "/lilypond/share/lilypond/${lilypond_version}" \
  && rm /tmp/install-system-fonts.sh /tmp/install-lilypond-fonts.sh \
  && fc-cache -fv



# Image with ly2video
FROM lilypond AS lilypond-ly2video

COPY install-ly2video.sh /tmp/

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
  && /tmp/install-ly2video.sh \
  && rm /tmp/install-ly2video.sh



# Image with both the fonts and ly2video
FROM lilypond-fonts AS lilypond-fonts-ly2video

COPY install-ly2video.sh /tmp/

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
  && /tmp/install-ly2video.sh \
  && rm /tmp/install-ly2video.sh



# Final image
# hadolint ignore=DL3006
FROM lilypond${suffix} AS final

LABEL maintainer="alexis.jeandeau@gmail.com"

# Cleanup
RUN apt-get remove -y bzip2 wget xz-utils build-essential python3-dev libasound-dev libjpeg-dev zlib1g-dev \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ARG username
ARG user_uid
ARG user_gid

# Add application (non-root) user and group
RUN groupadd --gid "${user_gid}" "${username}" \
    && useradd --uid "${user_uid}" --gid "${user_gid}" -m "${username}" \
    && chown -R "${user_uid}:${user_gid}" /app

USER ${username}

CMD ["lilypond", "-v"]
