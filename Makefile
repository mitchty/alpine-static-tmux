IMAGE:=alpine-static
TAR:=tar
.PHONY: docker all
.DEFAULT:

all: mosh mosh-client mosh-client.stripped mosh-server mosh-server.stripped htop htop.stripped tmux tmux.stripped pandoc pandoc.stripped

upx: mosh-client.upx mosh-client.stripped.upx mosh-server.upx mosh-server.stripped.upx htop.upx htop.stripped.upx tmux.upx tmux.stripped.upx pandoc.upx pandoc.stripped.upx
	upx --best --ultra-brute *.upx

dist: static.tar.xz

static.tar.xz:
	tar cvf static.tar mosh* tmux* htop* pandoc*
	xz -v9 static.tar

mosh-client.upx: mosh-client
	cp $< $@
mosh-client.stripped.upx: mosh-client.stripped
	cp $< $@
mosh-server.upx: mosh-server
	cp $< $@
mosh-server.stripped.upx: mosh-server.stripped
	cp $< $@
htop.upx: htop
	cp $< $@
htop.stripped.upx: htop.stripped
	cp $< $@
tmux.upx: tmux
	cp $< $@
tmux.stripped.upx: tmux.stripped
	cp $< $@
pandoc.upx: pandoc
	cp $< $@
pandoc.stripped.upx: pandoc.stripped
	cp $< $@

docker:
	docker build -t $(IMAGE) .

mosh: docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C .

mosh-client: docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C .
	
mosh-client.stripped: docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C .

mosh-server: docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C .
	
mosh-server.stripped: docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C .
htop: docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C .
	
htop.stripped: docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C .

tmux: docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C .
	
tmux.stripped: docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C .
	
pandoc: docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /root/.cabal/bin/$@ | $(TAR) xf - --strip-components=3 -C .

pandoc.stripped: docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /root/.cabal/bin/$@ | $(TAR) xf - --strip-components=3 -C .

clean:
	docker rmi -f $(IMAGE)
	-rm *.stripped mosh mosh-client mosh-server htop tmux
