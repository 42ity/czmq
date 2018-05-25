#!/usr/bin/env bash

case "$BUILD_TYPE" in
"") echo "BUILD_TYPE is not set!" >&2 ; false ;;
default|valgrind|selftest)
    CONFIG_OPTS=()
    if [ -n "$ADDRESS_SANITIZER" ] && [ "$ADDRESS_SANITIZER" == "enabled" ]; then
        CONFIG_OPTS+=("--enable-address-sanitizer=yes")
    fi

    if [ -n "${ZMQ_REPO}" ] && [ -z "${ZMQ_REPO_URL}" ]; then
        ZMQ_REPO_URL="git://github.com/zeromq/${ZMQ_REPO}.git"
    fi
    if [ -z "${ZMQ_REPO}" ] && [ -n "${ZMQ_REPO_URL}" ]; then
        ZMQ_REPO="`basename "${ZMQ_REPO_URL}" .git`"
    fi
    if [ -z "${ZMQ_REPO_URL}" ] || [ -z "${ZMQ_REPO}" ]; then
        echo "ERROR Determining libzmq repo to build against" >&2
        exit 1
    fi
    [ -n "${ZMQ_REPO_BRANCH}" ] || ZMQ_REPO_BRANCH="" ### Use github repo default
    [ -n "${ZMQ_CONFIG_OPTS_DRAFT}" ] || ZMQ_CONFIG_OPTS_DRAFT=no

    [ -n "${LIBSODIUM_REPO_URL}" ] || LIBSODIUM_REPO_URL="git://github.com/jedisct1/libsodium.git"
    [ -n "${LIBSODIUM_REPO_BRANCH}" ] || LIBSODIUM_REPO_BRANCH="stable"

    # Build, check, and install libsodium if WITH_LIBSODIUM is set
    if [ "$WITH_LIBSODIUM" = 1 ]; then
        echo "==== BUILD LIBSODIUM from $LIBSODIUM_REPO_URL '$LIBSODIUM_REPO_BRANCH' branch ===="
        git clone "$LIBSODIUM_REPO_URL" libsodium && \
        ( cd libsodium
          if [ -n "$LIBSODIUM_REPO_BRANCH" ] ; then git checkout "$LIBSODIUM_REPO_BRANCH" ; fi
          git rev-parse HEAD
          ./autogen.sh && ./configure "${CONFIG_OPTS[@]}" &&
            make check && sudo make install && sudo ldconfig ) || exit 1
    fi

    # Build, check, and install the version of ZeroMQ given by ZMQ_REPO
    echo "==== BUILD LIBZMQ from ${ZMQ_REPO_URL} '${ZMQ_REPO_BRANCH}' branch; ZMQ_CONFIG_OPTS_DRAFT='$ZMQ_CONFIG_OPTS_DRAFT' ===="
    git clone ${ZMQ_REPO_URL} ${ZMQ_REPO} &&
    ( cd ${ZMQ_REPO}
        if [ -n "$ZMQ_REPO_BRANCH" ] ; then git checkout "$ZMQ_REPO_BRANCH" ; fi
        if [ "$WITH_LIBSODIUM" = 1 ]; then CONFIG_OPTS+=("--with-libsodium=yes") ; else CONFIG_OPTS+=("--with-libsodium=no") ; fi
        git rev-parse HEAD; ./autogen.sh && ./configure "${CONFIG_OPTS[@]}" --enable-drafts="${ZMQ_CONFIG_OPTS_DRAFT}" &&
        make check && sudo make install && sudo ldconfig ) || exit 1

    # Build, check, and install CZMQ from local source
    echo "==== BUILD LIBCZMQ (current project checkout) ===="
    git rev-parse HEAD
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
