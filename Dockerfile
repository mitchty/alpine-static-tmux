from mitchty/alpine-ghc:latest

workdir /tmp

run apk update && apk upgrade && \
    apk add make gcc musl-dev linux-headers bash file curl bsd-compat-headers

env dest_prefix /usr

# libevent
env libevent_version 2.0.21
env libevent_name libevent-$libevent_version-stable
add https://github.com/downloads/libevent/libevent/$libevent_name.tar.gz /tmp/$libevent_name.tar.gz
run tar xvzf /tmp/$libevent_name.tar.gz && \
    cd $libevent_name && \
    ./configure --prefix=$dest_prefix --disable-shared && \
    make && \
    make install && \
    rm -fr /tmp/$libevent_name.tar.gz /tmp/$libevent_name

# ncurses
env ncurses_version 5.9
env ncurses_name ncurses-$ncurses_version
run curl -LO ftp://ftp.gnu.org/gnu/ncurses/$ncurses_name.tar.gz -o /tmp/$ncurses_name.tar.gz && \
    tar xvzf /tmp/$ncurses_name.tar.gz && \
    cd $ncurses_name && \
    ./configure --prefix=$dest_prefix --without-cxx --without-cxx-bindings --enable-static && \
    make && \
    make install && \
    rm -fr /tmp/$ncurses_name.tar.gz /tmp/$ncurses_name

# et tmux
env tmux_version 2.1
env tmux_name tmux-$tmux_version
env tmux_url $tmux_name/$tmux_name
add https://github.com/tmux/tmux/releases/download/$tmux_version/$tmux_name.tar.gz /tmp/$tmux_name.tar.gz
run tar xvzf /tmp/$tmux_name.tar.gz && \
    cd $tmux_name && \
    ./configure --prefix=$dest_prefix CFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="-static -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" && \
    env CPPFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="-static -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" make && \
    make install && \
    rm -fr /tmp/$tmux_name.tar.gz /tmp/$tmux_name

env htop_version 1.0.3
env htop_name htop-1.0.3
env htop_url http://hisham.hm/htop/releases/$htop_version/$htop_name.tar.gz
add $htop_url /tmp/$htop_name.tar.gz
run tar xvzf /tmp/$htop_name.tar.gz && \
    cd $htop_name && \
    ./configure --enable-static --disable-shared --disable-unicode --prefix=$dest_prefix CFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="--static -lpthread -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" && \
    env CPPFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="--static -lpthread -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" make && \
    make install && \
    rm -fr /tmp/$htop_name.tar.gz /tmp/$htop_name
run cp $dest_prefix/bin/htop $dest_prefix/bin/htop.stripped && strip $dest_prefix/bin/htop.stripped

env mosh_version 1.2.5
env mosh_name mosh-$mosh_version
env mosh_url https://github.com/mobile-shell/mosh/archive/$mosh_name.tar.gz
add $mosh_url /tmp/$mosh_name.tar.gz
run apk add autoconf automake protobuf-dev zlib-dev openssl-dev g++ && \
    tar xvzf /tmp/$mosh_name.tar.gz && \
    cd /tmp/mosh-$mosh_name && \
    ./autogen.sh && \
    ./configure --enable-static --disable-shared --prefix=$dest_prefix CFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="--static -lpthread -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" && \
    make && \
    make install && \
    rm -fr /tmp/mosh-$mosh_name

run cp $dest_prefix/bin/mosh-client $dest_prefix/bin/mosh-client.stripped && strip $dest_prefix/bin/mosh-client.stripped
run cp $dest_prefix/bin/mosh-server $dest_prefix/bin/mosh-server.stripped && strip $dest_prefix/bin/mosh-server.stripped

# pandoc
COPY static-ld-options.patch /tmp/static-ld-options.patch
workdir /tmp
run cabal update && cabal install hsb2hs && \
    cabal get pandoc
run cd /tmp/pandoc* && \
    mv /tmp/*.patch /tmp/pandoc* && \
    patch -p0 pandoc.cabal < static-ld-options.patch
run cd /tmp/pandoc* && cabal install --flags="embed_data_files"
env cabaldir /root/.cabal/bin
run cp $cabaldir/pandoc $cabaldir/pandoc.stripped && strip $cabaldir/pandoc.stripped

