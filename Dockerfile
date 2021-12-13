# ARGs used in FROM need to be declared before the first FROM
# See https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG suffix=""
ARG lilypond_version="2.22.0"
ARG username=lilypond
ARG user_uid=1000
ARG user_gid=$user_uid



FROM debian:bullseye-slim AS build

USER root

ARG username
ARG user_uid
ARG user_gid

# Add application (non-root) user and group
RUN groupadd --gid "${user_gid}" "${username}" \
    && useradd --uid "${user_uid}" --gid "${user_gid}" -m "${username}"

RUN printf 'LANG="C"\nLANGUAGE="C"\nLC_ALL="C"\n' > /etc/default/locale \
  && source /etc/default/locale \
  && echo "deb-src http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list \
  && apt-get update \
  # Install the LilyPond build dependencies
  && apt-get build-dep -y lilypond \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20210119 \
    # To get newer config.sub and config.guess
    autotools-dev=20180224.1+nmu1 \
    # LilyPond build dependencies
    git=1:2.30.2-1 \
    guile-2.2-dev=2.2.7+1-6 \
    install-info=6.7.0.dfsg.2-6 \
    python-is-python3=3.9.2-1

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

USER ${username}



FROM debian:bullseye-slim AS lilypond

USER root

RUN printf 'LANG="C"\nLANGUAGE="C"\nLC_ALL="C"\n' > /etc/default/locale

# hadolint ignore=DL3009
RUN source /etc/default/locale \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20210119 \
    # LilyPond run dependencies
    libglib2.0-0=2.66.8-1 \
    guile-2.2=2.2.7+1-6 \
    libpangoft2-1.0-0=1.46.2-3 \
    fontconfig=2.13.1-4.2 \
    fonts-dejavu=2.37-2 \
    ghostscript=9.53.3~dfsg-7+deb11u1 \
    # For convert-ly
    python-is-python3=3.9.2-1 \
    # LilyPond optional dependencies
    extractpdfmark=1.1.0-1.1 \
    # To transform PDFs (e.g. rotate)
    qpdf=10.1.0-1

COPY --from=build /lilypond /lilypond

ENV PATH "/lilypond/bin:${PATH}"

ARG username

USER ${username}



# Image with the fonts
FROM lilypond AS lilypond-fonts

USER root

COPY install-lilypond-fonts.sh install-system-fonts.sh /tmp/

ARG lilypond_version

# Install fonts for LilyPond
RUN apt-get install -y --no-install-recommends \
  fontconfig=2.13.1-4.2 \
  # Required by install-lilypond-fonts.sh and install-system-fonts.sh
  wget=1.21-1+b1 \
  xz-utils=5.2.5-2 \
  # System font installation through the repositories
  fonts-ipafont=00303-21 \
  fonts-ipaexfont=00401-3 \
  fonts-hanazono=20170904-2.1 \
  fonts-noto-core=20201225-1 \
  fonts-noto-cjk=1:20201206-cjk+repack1-1 \
  # Manual system font installation (not in the repositories)
  && /tmp/install-system-fonts.sh \
  # LilyPond font installation
  && /tmp/install-lilypond-fonts.sh "/lilypond/share/lilypond/${lilypond_version}" \
  && rm /tmp/install-system-fonts.sh /tmp/install-lilypond-fonts.sh \
  && fc-cache -fv

ARG username

USER ${username}



# Image with ly2video
FROM lilypond AS lilypond-ly2video

USER root

COPY install-ly2video.sh /tmp/

# Install ly2video
RUN apt-get install -y --no-install-recommends \
  git=1:2.30.2-1 \
  # Required by ly2video
  ffmpeg=7:4.3.2-0+deb11u2 \
  timidity=2.14.0-8 \
  fluid-soundfont-gm=3.1-5.2 \
  fluid-soundfont-gs=3.1-5.2 \
  build-essential=12.9 \
  python3-pip=20.3.4-4 \
  python3-pil=8.1.2+dfsg-0.3 \
  python3-dev=3.9.2-3 \
  swig=4.0.2-1 \
  libasound2-dev=1.2.4-1.1 \
  # Required by Pillow
  libjpeg-dev=1:2.0.6-4 \
  zlib1g-dev=1:1.2.11.dfsg-2 \
  && /tmp/install-ly2video.sh \
  && rm /tmp/install-ly2video.sh

ARG username

USER ${username}



# Image with both the fonts and ly2video
FROM lilypond-fonts AS lilypond-fonts-ly2video

USER root

COPY install-ly2video.sh /tmp/

# Install ly2video
RUN apt-get install -y --no-install-recommends \
  git=1:2.30.2-1 \
  # Required by ly2video
  ffmpeg=7:4.3.2-0+deb11u2 \
  timidity=2.14.0-8 \
  fluid-soundfont-gm=3.1-5.2 \
  fluid-soundfont-gs=3.1-5.2 \
  build-essential=12.9 \
  python3-pip=20.3.4-4 \
  python3-pil=8.1.2+dfsg-0.3 \
  python3-dev=3.9.2-3 \
  swig=4.0.2-1 \
  libasound2-dev=1.2.4-1.1 \
  # Required by Pillow
  libjpeg-dev=1:2.0.6-4 \
  zlib1g-dev=1:1.2.11.dfsg-2 \
  && /tmp/install-ly2video.sh \
  && rm /tmp/install-ly2video.sh

ARG username

USER ${username}



# Final image
# hadolint ignore=DL3006
FROM lilypond${suffix} AS final

LABEL maintainer="alexis.jeandeau@gmail.com"

USER root

# Cleanup
RUN apt-get remove -y bzip2 wget xz-utils build-essential python3-dev libasound-dev libjpeg-dev zlib1g-dev \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ARG username
ARG user_uid
ARG user_gid

RUN chown -R "${user_uid}:${user_gid}" /app

USER ${username}

CMD ["lilypond", "-v"]
