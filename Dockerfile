from alpine:latest

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
env tmux_version 2.0
env tmux_name tmux-$tmux_version
env tmux_url $tmux_name/$tmux_name
add https://github.com/tmux/tmux/releases/download/$tmux_version/$tmux_name.tar.gz /tmp/$tmux_name.tar.gz
run tar xvzf /tmp/$tmux_name.tar.gz && \
    cd $tmux_name && \
    ./configure --prefix=$dest_prefix CFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="-static -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" && \
    env CPPFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="-static -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" make && \
    make install && \
    rm -fr /tmp/$tmux_name.tar.gz /tmp/$tmux_name

run file $dest_prefix/bin/tmux
