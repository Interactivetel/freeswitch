#!/usr/bin/env bash
set -eE

# move to script directory so all relative paths work
cd "$(dirname "$0" 2>/dev/null)"

# include files
. lib.sh


usage() {
    info "::: Description:"
    info ":::   Installs FreeSWITCH under: /usr/local/freeswitch "
    info "::: "
    info "::: Supported systems:"
    info ":::   CentOS, RedHat, Debian"
    info "::: "
    info "::: Usage:"
    info ":::   install.sh [-h|--help]"
    info "::: "
    info ":::   -h|--help: show this message"
    info ":::"
    info "::: Ej."
    info ":::   # install FreeSWITCH under: /usr/local/freeswitch"
    info ":::   install.sh"
    info "::: "
}

install-freeswitch() {
    INSTALL_DIR=/usr/local/freeswitch
    header "Installing FreeSWITCH under: $INSTALL_DIR"

    # detect the linux distro
    system-detect
    if [[ "$BASE_DIST" != "redhat" && "$BASE_DIST" != "debian" ]]; then
      abort "::: We only support Debian and CentOS based linux distributions"
    fi

    install-default-repos
    install-custom-repos

    info "\n::: Installing build dependencies\n"
    if [[ "$BASE_DIST" = "redhat" ]]; then
      sudo yum -y install tar unzip git pkgconfig autoconf make automake libtool libtool-ltdl uuid-devel unixODBC-devel \
        libjpeg-devel libtiff-devel zlib-devel bzip2-devel xz-devel gdbm-devel ncurses-devel expat-devel \
        ldns-devel libedit-devel nasm yasm sqlite-devel curl-devel openssl-devel gnutls-devel pcre-devel speex-devel \
        libzrtpcpp-devel libsndfile-devel flac-devel libogg-devel libvorbis-devel libxml2-devel wanpipe

      sudo yum -y install devtoolset-9 pkgconfig
      source /opt/rh/devtoolset-9/enable
    elif [[ "$BASE_DIST" = "debian" ]]; then
      sudo apt -y update && sudo apt -y upgrade
      sudo apt -y install tar unzip git build-essential libtool libtool-bin libltdl7 libltdl-dev uuid-dev \
        unixodbc-dev libjpeg-dev libtiff-dev zlib1g-dev libbz2-dev xz-utils liblzma-dev libgdbm-dev \
        libncurses5-dev libncursesw5-dev libexpat1-dev libldns-dev libedit-dev nasm yasm \
        libsqlite3-dev libpcre3-dev libspeex-dev libspeexdsp-dev libcurl4-gnutls-dev \
        libbzrtp-dev libsndfile1-dev libflac-dev libogg-dev libvorbis-dev wanpipe \
        gcc-9 g++-9
    fi

    # create build dir
    BUILD_DIR=$(mktemp -d -t freeswitch.XXX)
#    BUILD_DIR=/tmp/freeswitch-build && mkdir -p $BUILD_DIR && rm -rf $BUILD_DIR/*
    trap 'rm -rf "${BUILD_DIR}"' EXIT

    # remove old installs
    sudo rm -rf "$INSTALL_DIR"

    # create install dir structure
    INCLUDE_DIR="$INSTALL_DIR/include"
    LIB_DIR="$INSTALL_DIR/lib"
    sudo mkdir -p "$INCLUDE_DIR" "$LIB_DIR"

    # copy over Sangoma SDK and libsng_isdn libs and include files
    info "\n::: Installing Sangoma Decoder lib\n"
    curl -k -L -o "$BUILD_DIR/sangoma-tdm-sdk-v1.0.21_GA.x86_64.zip" https://packages.interactivetel.com/libs/sangoma-tdm-sdk-v1.0.21_GA.x86_64.zip
    unzip -d "$BUILD_DIR" "$BUILD_DIR/sangoma-tdm-sdk-v1.0.21_GA.x86_64.zip"
    sudo mkdir -p "$INCLUDE_DIR/sng_decoder"
    sudo cp "$BUILD_DIR"/sangoma-tdm-sdk-v1.0.21_GA.x86_64/libs/decoders/sng_decoder/cm/* "$INCLUDE_DIR/sng_decoder/"
    sudo cp "$BUILD_DIR"/sangoma-tdm-sdk-v1.0.21_GA.x86_64/libs/decoders/sng_decoder/src/libsng_decoder.so.1.0.0 "$LIB_DIR"
    sudo ln -sf libsng_decoder.so.1.0.0 "$LIB_DIR/libsng_decoder.so"

    info "\n::: Installing Sangoma ISDN lib\n"
    curl -k -L -o "$BUILD_DIR/libsng_isdn-current.x86_64.tgz" https://packages.interactivetel.com/libs/libsng_isdn-current.x86_64.tgz
    tar -C "$BUILD_DIR" -xzf "$BUILD_DIR/libsng_isdn-current.x86_64.tgz"
    pushd "$BUILD_DIR/libsng_isdn-8.3.4.x86_64" >/dev/null 2>&1
    sudo make DESTDIR="$INSTALL_DIR" install
    popd >/dev/null 2>&1

    if [[ "$BASE_DIST" = "debian" ]]; then
      # we need openssl v1.0.1e
      info "\n::: Installing OpenSSL: v1.0.1e\n"
      curl -k -L -o "$BUILD_DIR/openssl.tar.gz" "https://www.openssl.org/source/old/1.0.1/openssl-1.0.1e.tar.gz"
      tar -C "$BUILD_DIR" -xzf "$BUILD_DIR/openssl.tar.gz"
      pushd "$BUILD_DIR"/openssl-* >/dev/null 2>&1
      ./config --prefix="${INSTALL_DIR}" --openssldir="${INSTALL_DIR}" "-s -Wl,-rpath=${INSTALL_DIR}/lib" shared

      make
      sudo make install_sw
      sudo rm -f "${INSTALL_DIR}"/bin/{c_rehash,openssl}
      sudo rm -f "${INSTALL_DIR}"/lib/*.a
      sudo rm -rf "${INSTALL_DIR}"/{certs,misc,private,openssl.cnf}
      popd >/dev/null 2>&1
    fi

    # build freeswitch
    info "\n::: Compiling and Installing FreeSWITCH v1.6\n"

    mkdir -p "$BUILD_DIR/freeswitch"
    cp -a .. "$BUILD_DIR/freeswitch"
    cp modules.conf "$BUILD_DIR/freeswitch"
    pushd "$BUILD_DIR/freeswitch" >/dev/null 2>&1
    ./bootstrap.sh -j

    if [[ "$BASE_DIST" = "debian" ]]; then
      ./configure --prefix="$INSTALL_DIR" --disable-fhs -disable-debug \
        CC=gcc-9 CXX=g++-9 \
        CFLAGS="-fgnu89-inline" \
        CPPFLAGS="-Wno-error=stringop-truncation -Wno-error=format-overflow -Wno-error=memset-elt-size -Wno-error=parentheses -I$INCLUDE_DIR/sng_decoder -I$INCLUDE_DIR/sng_isdn -I$INCLUDE_DIR" \
        LDFLAGS="-L$LIB_DIR -s -Wl,-rpath=$LIB_DIR"
    else
      ./configure --prefix="$INSTALL_DIR" --disable-fhs -disable-debug \
        CFLAGS="-fgnu89-inline" \
        CPPFLAGS="-Wno-error=stringop-truncation -Wno-error=format-overflow -Wno-error=memset-elt-size -I$INCLUDE_DIR/sng_decoder -I$INCLUDE_DIR/sng_isdn -I$INCLUDE_DIR" \
        LDFLAGS="-L$LIB_DIR -s -Wl,-rpath=$LIB_DIR"
    fi

    make
    sudo make install
    popd >/dev/null 2>&1

    # copy our config files
    sudo rm -rf "$INSTALL_DIR"/conf/*
    sudo cp -a conf/* "$INSTALL_DIR"/conf/
    info "Finished"
}

# parameter check
if [[ $# = 0 ]]; then
    install-freeswitch
elif [[ $# = 1 ]]; then
    if [[ "$1" = "-h" || "$1" = "--help" ]]; then
        usage
    else
        error "::: Invalid options, check the help: $*"
    fi
else
    error "::: Invalid options, check the help: $*"
fi

