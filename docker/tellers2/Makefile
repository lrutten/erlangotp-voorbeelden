build:
	docker build -t lrutten/erlang-tellers2 .

network-create:
	docker network create --subnet 172.20.0.0/16 lokaal

network-ls:
	docker network ls

network-inspect:
	docker network inspect lokaal

network-rm:
	docker network rm lokaal

erl1:
	docker -D run --name huis1 -it --rm --dns-search=straat.org --net=lokaal -h huis1 --network-alias=huis1.straat.org -p 8080:8080 lrutten/erlang-tellers2

erl2:
	docker -D run --name huis2 -it --rm --dns-search=straat.org --net=lokaal -h huis2 --network-alias=huis2.straat.org -p 8081:8080 lrutten/erlang-tellers2

bash1:
	docker -D run --name huis1 -it --rm --dns-search=straat.org --net=lokaal -h huis1 --network-alias=huis1.straat.org lrutten/erlang /bin/bash

bash2:
	docker -D run --name huis2 -it --rm --dns-search=straat.org --net=lokaal -h huis2 --network-alias=huis2.straat.org lrutten/erlang /bin/bash

exbash1:
	docker exec -it huis1 /bin/bash

exbash2:
	docker exec -it huis2 /bin/bash



stop1:
	docker stop huis1

stop2:
	docker stop huis2


images:
	docker images

