IMAGE:=alpine-static
TAR:=tar
.PHONY: docker all
.DEFAULT:

TARGETS:=mosh mosh-client mosh-client.stripped mosh-server mosh-server.stripped htop htop.stripped tmux tmux.stripped jq jq.stripped
GHCTARGETS:=pandoc pandoc.stripped
ALLTARGETS:=$(TARGETS) $(GHCTARGETS)

all: $(ALLTARGETS)

UPXS:=mosh-client.stripped.upx mosh-server.stripped.upx htop.stripped.upx tmux.stripped.upx pandoc.stripped.upx jq.stripped.upx

upx: $(UPXS)

dist: static.tar.xz

static.tar.xz: upx
	tar cvf static.tar $(UPXS)
	xz -T0 -v9 static.tar

jq.stripped.upx: jq.stripped
	cp $< $@
	upx --best --ultra-brute $@
mosh-client.stripped.upx: mosh-client.stripped
	cp $< $@
	upx --best --ultra-brute $@
mosh-server.stripped.upx: mosh-server.stripped
	cp $< $@
	upx --best --ultra-brute $@
htop.stripped.upx: htop.stripped
	cp $< $@
	upx --best --ultra-brute $@
tmux.stripped.upx: tmux.stripped
	cp $< $@
	upx --best --ultra-brute $@
pandoc.stripped.upx: pandoc.stripped
	cp $< $@
	upx --best --ultra-brute $@

docker:
	docker build -t $(IMAGE) .

$(TARGETS): docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C .
	
$(GHCTARGETS): docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /root/.cabal/bin/$@ | $(TAR) xf - --strip-components=3 -C .

clean:
	-rm *.upx $(ALLTARGETS)

distclean: clean
	-rm static.tar.xz

dockerclean:
	docker rmi -f $(IMAGE):latest
