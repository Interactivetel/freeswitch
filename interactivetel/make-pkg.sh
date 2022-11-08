#!/usr/bin/env bash
set -eE
cd "$(dirname "$0")"

. lib.sh
. freeswitch_version


usage() {
    info "::: Description:"
    info ":::   Create a binary package (rpm, deb) for FreeSWITCH drivers."
    info ":::"
    info "::: Supported systems:"
    info ":::   Debian, Ubuntu, CentOS and RedHat."
    info ":::"
    info "::: Usage:"
    info ":::   make-pkg.sh [ -h | --help ]"
    info ":::"
    info ":::   -h | --help: Show this message"
    info ":::   The script will automatically detect you linux distro and create the package (rpm|deb) accordingly"
    info ":::"
    info "::: Ej:"
    info ":::   ./make-pkg.sh"
    info ":::"
}

make-package() {
    # detect the running we are running on
    system-detect
    if [[ ! "$BASE_DIST" = "debian" && ! "$BASE_DIST" = "redhat"  ]]; then
      abort "Unsupported linux distribution: $BASE_DIST/$DIST-$VER"
    fi

    if [[ "$BASE_DIST" = "redhat" ]]; then
      sudo yum -y install rpmdevtools
    fi

    # check for FPM command and install it if not found
    command -v fpm &>/dev/null || {
        header "Installing FPM"
        if [[ "$BASE_DIST" = "debian" ]]; then
            sudo apt-get -y install ruby
            sudo gem install fpm
        else
            install-default-repos
            command -v rvm || {
                command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
                command curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
                curl -sSL https://get.rvm.io | bash -s stable
            }

            source "$HOME/.rvm/scripts/rvm"
            command -v ruby || rvm install ruby
            command -v fpm || gem install fpm
        fi
        echo
    }

    # install freeswitch: /usr/local/freeswitch
    ./install.sh
    echo

    # finally make the package with FPM
    header "Creating FreeSWITCH package from: /usr/local/freeswitch"
    if [[ "$BASE_DIST" == "debian" ]]; then
      fpm \
          -s dir -t deb --force -a amd64 \
          --name freeswitch --version "$VERSION" --iteration "$ITER~$DIST$VER" \
          --license "GPL" --vendor "InteractiveTel" \
          --maintainer 'Jose Rodriguez Bacallao <jrodriguez@interactivetel.com>' \
          --description 'FreeSWITCH: Software Defined Telecom Stack' \
          --url 'https://github.com/Interactivetel/freeswitch' --category 'comm' \
          -d libltdl-dev -d uuid-dev -d unixodbc-dev -d libjpeg-dev -d libtiff-dev -d zlib1g-dev -d libbz2-dev \
          -d xz-utils -d liblzma-dev -d libgdbm-dev -d libncurses5-dev -d libncursesw5-dev -d libexpat1-dev \
          -d libldns-dev -d libedit-dev -d libsqlite3-dev -d libpcre3-dev -d libspeex-dev -d libspeexdsp-dev \
          -d libcurl4-gnutls-dev -d libbzrtp-dev -d libsndfile1-dev -d libflac-dev -d libogg-dev \
          -d libvorbis-dev -d wanpipe \
          --config-files "/usr/local/freeswitch/conf" \
          --after-install "./dist/after-install.sh" \
          --after-upgrade "./dist/after-upgrade.sh" \
          --before-remove "./dist/before-remove.sh" \
          --after-remove "./dist/after-remove.sh" \
          --deb-after-purge "./dist/after-purge.sh" \
          --deb-compression xz --deb-dist stable \
          --deb-no-default-config-files \
          /usr/local/freeswitch
    else
      TAG=$(echo "$VER" | cut -d '.' -f 1)
      fpm \
        -s dir -t rpm --force -a x86_64 \
        --name freeswitch --version "$VERSION" --iteration "$ITER" \
        --license "GPL" --vendor "InteractiveTel" \
        --maintainer 'Jose Rodriguez Bacallao <jrodriguez@interactivetel.com>' \
        --description 'FreeSWITCH: Software Defined Telecom Stack' \
        --url 'https://github.com/Interactivetel/freeswitch' --category 'Applications/Communications' \
        -d uuid-devel -d unixODBC-devel -d libjpeg-devel -d libtiff-devel -d zlib-devel -d bzip2-devel -d xz-devel \
        -d gdbm-devel -d ncurses-devel -d expat-devel -d ldns-devel -d libedit-devel -d sqlite-devel -d curl-devel \
        -d openssl-devel -d gnutls-devel -d pcre-devel -d speex-devel -d libzrtpcpp-devel -d libsndfile-devel \
        -d flac-devel -d libogg-devel -d libvorbis-devel -d libxml2-devel -d wanpipe \
        --config-files "/usr/local/freeswitch/conf" \
        --after-install "./dist/after-install.sh" \
        --after-upgrade "./dist/after-upgrade.sh" \
        --before-remove "./dist/before-remove.sh" \
        --after-remove "./dist/after-remove.sh" \
        --rpm-compression xz --rpm-dist "el$TAG" --rpm-os linux \
        /usr/local/freeswitch
    fi

    # finally remove install, we are just making a package
    sudo rm -rf /usr/local/freeswitch
}

if [[ $# -eq 0 ]]; then
    make-package
elif [[ $# -eq 1 ]]; then
    if [[ "$1" = "-h" || "$1" = "--help" ]]; then
        usage
    else
      abort "Invalid options, check the help: $*"
    fi
else
    abort "Invalid options, check the help: $*"
fi
