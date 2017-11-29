build:
	docker build -t lrutten/erlang-tellers .

network-create:
	docker network create lokaal

network-ls:
	docker network ls

erl1:
	docker -D run --name huis1 -it --rm --dns-search=straat.org --net=lokaal -h huis1 --network-alias=huis1.straat.org -p 8080:8080 lrutten/erlang-tellers

erl2:
	docker -D run --name huis2 -it --rm --dns-search=straat.org --net=lokaal -h huis2 --network-alias=huis2.straat.org -p 8081:8080 lrutten/erlang-tellers

bash1:
	docker -D run --name huis1 -it --rm --dns-search=straat.org --net=lokaal -h huis1 --network-alias=huis1.straat.org lrutten/erlang-tellers /bin/bash

bash2:
	docker -D run --name huis2 -it --rm --dns-search=straat.org --net=lokaal -h huis2 --network-alias=huis2.straat.org lrutten/erlang-tellers /bin/bash



stop1:
	docker stop huis1

stop2:
	docker stop huis2


images:
	docker images

