IMAGE:=alpine-static-tmux
EXE:=tmux
TAR:=tar
.PHONY: docker

all: $(EXE)

docker:
	docker build -t $(IMAGE) .

$(EXE): docker
	docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$(EXE) | $(TAR) xf - --strip-components=2 -C .
	
	
clean:
	docker rmi -f $(IMAGE)

