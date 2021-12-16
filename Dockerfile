# ARGs used in FROM need to be declared before the first FROM
# See https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG SUFFIX=""
ARG LILYPOND_VERSION="2.22.0"
ARG USERNAME=lilypond
ARG USER_UID=1000
ARG USER_GID=$USER_UID



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

ARG LILYPOND_VERSION

# Install LilyPond
RUN git clone --no-tags --single-branch --branch "release/${LILYPOND_VERSION}-1" https://git.savannah.gnu.org/git/lilypond.git

WORKDIR /build/lilypond

RUN ./autogen.sh --noconfigure \
  # Update the configure script (required to build on arm64)
  && cp /usr/share/misc/config.sub /usr/share/misc/config.guess ./config/ \
  && mkdir build

WORKDIR /build/lilypond/build

RUN mkdir /lilypond \
  && ../configure --prefix /lilypond --disable-debugging --disable-documentation \
  && make -j"$(nproc)" \
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

ARG LILYPOND_VERSION

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
  && /tmp/install-lilypond-fonts.sh "/lilypond/share/lilypond/${LILYPOND_VERSION}" \
  && rm /tmp/install-system-fonts.sh /tmp/install-lilypond-fonts.sh \
  && fc-cache -fv



# Image with ly2video and Spontini
FROM lilypond AS lilypond-tools

COPY install-ly2video.sh install-spontini.sh /tmp/

# Install ly2video and Spontini
RUN apt-get install -y --no-install-recommends \
    git \
    wget \
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
    # Required by Spontini
    python3-venv \
  && /tmp/install-ly2video.sh \
  && /tmp/install-spontini.sh \
  && rm /tmp/install-ly2video.sh /tmp/install-spontini.sh



# Image with both the fonts and tools (ly2video and Spontini)
FROM lilypond-fonts AS lilypond-fonts-tools

COPY install-ly2video.sh install-spontini.sh /tmp/

# Install ly2video and Spontini
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
    # Required by Spontini
    python3-venv \
  && /tmp/install-ly2video.sh \
  && /tmp/install-spontini.sh \
  && rm /tmp/install-ly2video.sh /tmp/install-spontini.sh



# Final image
# hadolint ignore=DL3006
FROM lilypond${SUFFIX} AS final

LABEL maintainer="alexis.jeandeau@gmail.com"

# Cleanup
RUN apt-get remove -y bzip2 wget xz-utils build-essential python3-dev libasound-dev libjpeg-dev zlib1g-dev \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ARG USERNAME
ARG USER_UID
ARG USER_GID

# Add application (non-root) user and group
RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" \
    && chown -R "${USER_UID}:${USER_GID}" /app \
    && if [ -d /opt/Spontini ]; then chown -R "${USER_UID}:${USER_GID}" /opt/Spontini; fi

USER $USERNAME

CMD ["lilypond", "-v"]
