#!/usr/bin/env bash

case "$BUILD_TYPE" in
"") echo "BUILD_TYPE is not set!" >&2 ; false ;;
default|valgrind|selftest)
    CONFIG_OPTS=()
    if [ -n "$ADDRESS_SANITIZER" ] && [ "$ADDRESS_SANITIZER" == "enabled" ]; then
        CONFIG_OPTS+=("--enable-address-sanitizer=yes")
    fi

    # Build, check, and install libsodium if WITH_LIBSODIUM is set
    if [ "$WITH_LIBSODIUM" = 1 ]; then
        echo "==== BUILD LIBSODIUM from git://github.com/jedisct1/libsodium.git stable branch ===="
#        git clone git://github.com/jedisct1/libsodium.git &&
        git clone -b stable git://github.com/jedisct1/libsodium.git &&
        ( cd libsodium; ./autogen.sh && ./configure "${CONFIG_OPTS[@]}" &&
            make check && sudo make install && sudo ldconfig ) || exit 1
    fi

    # Build, check, and install the version of ZeroMQ given by ZMQ_REPO
    echo "==== BUILD LIBZMQ from git://github.com/zeromq/${ZMQ_REPO}.git ===="
    git clone git://github.com/zeromq/${ZMQ_REPO}.git &&
    ( cd ${ZMQ_REPO}; ./autogen.sh && ./configure "${CONFIG_OPTS[@]}" &&
        make check && sudo make install && sudo ldconfig ) || exit 1

    # Build, check, and install CZMQ from local source
    echo "==== BUILD LIBCZMQ (current project checkout) ===="
    ./autogen.sh && ./configure "${CONFIG_OPTS[@]}" && \
    case "$BUILD_TYPE" in
        default) make check-verbose VERBOSE=1 && sudo make install ;;
        selftest) ASAN_OPTIONS=verbosity=1 make check-verbose ;;
        valgrind) make memcheck ;;
        *) echo "Unknown BUILD_TYPE" 2>&1; false ;;
    esac
    ;;
*)
    cd ./builds/${BUILD_TYPE} && ./ci_build.sh
esac
