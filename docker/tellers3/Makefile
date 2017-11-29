build:
	docker build -t lrutten/erlang-tellers3 .

network-create:
	docker network create --driver overlay --subnet 172.21.0.0/16 labo

network-ls:
	docker network ls

network-inspect:
	docker network inspect labo

network-rm:
	docker network rm labo

swarm-init:
	docker swarm init --advertise-addr $(ip-address)

node-ls:
	docker node ls

service-create:
	docker service create --replicas 2 --network labo --host=host-1:172.21.0.3 --host=host-2:172.21.0.4 --name teller --hostname="host-{{.Task.Slot}}" --publish 80:8080 lrutten/erlang-tellers3
	#docker service create --replicas 2 --network labo --name teller --hostname="host-{{.Task.Slot}}" --publish 80:8080 lrutten/erlang-tellers3
	#docker service create --replicas 2 --network labo --dns-search=straat.org --name teller --hostname="host-{{.Task.Slot}}" --publish 80:8080 lrutten/erlang-tellers3
	#docker service create --replicas 2 --network labo --name teller --publish 80:8080 lrutten/erlang-tellers3

service-ls:
	docker service ls

service-inspect:
	docker service inspect --pretty teller

service-ps:
	docker service ps teller

service-logs:
	docker service logs teller

service-logs-follow:
	docker service logs --follow teller

ps:
	docker ps

service-scale:
	docker service scale teller=3

service-rm:
	docker service rm teller




