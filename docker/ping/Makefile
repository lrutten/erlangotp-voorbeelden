build:
	docker build -t lrutten/erlang-ping .

network-create:
	docker network create lokaal

network-ls:
	docker network ls

erl1:
	docker -D run --name huis1 -it --rm --dns-search=straat.org --net=lokaal -h huis1 --network-alias=huis1.straat.org lrutten/erlang-ping erl -name huis1@huis1.straat.org -setcookie abc

erl2:
	docker -D run --name huis2 -it --rm --dns-search=straat.org --net=lokaal -h huis2 --network-alias=huis2.straat.org lrutten/erlang-ping erl -name huis2@huis2.straat.org -setcookie abc

bash1:
	docker -D run --name huis1 -it --rm --dns-search=straat.org --net=lokaal -h huis1 --network-alias=huis1.straat.org lrutten/erlang-ping /bin/bash

bash2:
	docker -D run --name huis2 -it --rm --dns-search=straat.org --net=lokaal -h huis2 --network-alias=huis2.straat.org lrutten/erlang-ping /bin/bash



stop1:
	docker stop huis1

stop2:
	docker stop huis2


images:
	docker images

