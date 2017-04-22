IMAGE:=alpine-static
TAR:=tar
OUT:=out
.PHONY: docker all
.DEFAULT:

UPXS:=mosh-client.stripped.upx mosh-server.stripped.upx htop.stripped.upx tmux.stripped.upx jq.stripped.upx
TARGETS:=mosh mosh-client mosh-client.stripped mosh-server mosh-server.stripped htop htop.stripped tmux tmux.stripped jq jq.stripped $(UPXS)
GHCUPXS:=pandoc.stripped.upx pandoc.upx
GHCTARGETS:=pandoc pandoc.stripped $(GHCUPXS)
ALLTARGETS:=$(TARGETS) $(GHCTARGETS)

all: $(ALLTARGETS)


upx: $(UPXS)

$(OUT):
	install -dm755 $@

dist: $(TARGETS) $(GHCTARGETS) static.tar.xz

static.tar.xz: upx
	(cd $(OUT) && tar cvf ../static.tar $(TARGETS) $(GHCTARGETS))
	xz -T0 -v9 static.tar

docker:
	docker build -t $(IMAGE) .

$(TARGETS): docker $(OUT)
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C $(OUT)
	
$(GHCTARGETS): docker $(OUT)
	docker run -a stdout $(IMAGE) /bin/tar -cf - /root/.cabal/bin/$@ | $(TAR) xf - --strip-components=3 -C $(OUT)

clean:
	-rm *.upx $(ALLTARGETS)

distclean: clean
	-rm static.tar.xz

dockerclean:
	docker rmi -f $(IMAGE):latest
