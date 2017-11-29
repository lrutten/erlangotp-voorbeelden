% Erlang in Docker
% L. Rutten
% 29/11/2017

Deze tekst beschrijft een aantal testen die nagaan of het eenvoudig
en nuttig is om Erlang programma's in Docker containers uit te testen.
Het belangrijkste doel is nagaan of de delen van een gedistribueerde Erlang applicatie
in meerdere containercompartimenten kunnen geplaatst worden. Elke container
moet dan op een aparte host draaien. Het voordeel van deze spreiding is dat 
de CPU belasting per PC laag gehouden kan worden.

# `ping` test met 2 containers

Dit is de `Dockerfile` voor de image waarmee getest wordt.
Er wordt de laatste Erlang versie gebruikt. De commando's `rebar` en `rebar3` zitten er ook in.
Het pakket `dnsutils` bevat het `dig` commando.

De `epmd` daemon gebruikt poort 4369 zodat via deze poort
kan opgevraag worden via welk poort een Erlang node kan bereikt worden.
Wanneer `epmd` draait, kan met `epmd -names` dir opgevraagd worden.
Deze poort zit mee in het bereik van de `EXPOSE`.

Dit is de `Dockerfile`.

~~~~
FROM erlang:19.1.6

RUN apt-get update
RUN apt-get install -y dnsutils

EXPOSE 4000-50000

CMD [erl]
~~~~

De gebruikte versie van `docker` is versie `1.12.4-rc4`. 
Af en toe blokkeert de laatste versie `1.12.1` maar de laatste release candidate heeft dat ook gedaan.
In elk geval is een post `1.12.0` versie nodig omdat de containers in een eigen netwerk
moeten kunnen draaien; anders lukt de ping niet.

Het netwerk wordt zo gemaakt:

~~~~
docker network create lokaal
~~~~

`lokaal` is de naam van het netwerk.
Het subnet is dan `172.19.0.0/16` en de 
gateway is dan `172.19.0.1/16`. Het netwerk kan bekeken worden met:

~~~~
docker network inspect lokaal
~~~~

Het voordeel van een eigen netwerk is dat hierdoor de container elkaar gemakkelijker vinden.
Het netwerk krijgt een eigen embedded DNS server. Tijdens de testen kan je die met `dig` testen.
Deze DNS server zit op adres `127.0.0.11`. Het is mogelijk om extra records te laten bijvoegen in de
database van deze server.

Het volgende commando start de container:

~~~~
docker run \
  --name huis1 \
  -it \
  --rm \
  --dns-search=straat.org \
  --net=lokaal \
  -h huis1 \
  --network-alias=huis1.straat.org \
  lrutten/erlang \
  /bin/bash
~~~~

De opties hebben de volgende betekenis:

* `--name huis1` dit is de naam van de container
* `-it` de container werkt iteratief
* `--rm` na het stoppen van de container wordt die verwijderd
* `--dns-search=straat.org` zorgt voor de `search` optie in `/etc/resolv.conf`
* `--net=lokaal` deze container wordt in het `lokaal` netwerk geplaatst
* `-h huis` dit is de hostname
* `--network-alias=huis1.straat.org` dit is een extra domainnaam voor het netwerk. Anders werkt de ping met de FQDN niet.
* `lrutten/erlang` de gebruikte image
* `/bin/bash` het gestarte commando, dat kan ook `erl` zijn.

In de container ziet `/etc/resolv.conf` er dan zo uit:

~~~~
search straat.org
nameserver 127.0.0.11
options ndots:0
~~~~

Het bestand `/etc/resolv.conf` heeft zijn eigen mount en komt niet uit de image.
Zo kan je elke container andere instellingen geven ook al werk je met dezelfde image.
Dit geldt ook voor `/etc/hostname` en `/etc/hosts`.

De connectie tussen de containers/nodes lukt met de gebruikelijke `net_adm:ping()` commando's.


Dit is de  `Makefile`:

~~~~
build:
	docker build -t lrutten/erlang .

network-create:
	docker network create lokaal

network-ls:
	docker network ls

erl1:
	docker -D run --name huis1 -it --rm --dns-search=straat.org --net=lokaal -h huis1 --network-alias=huis1.straat.org lrutten/erlang erl -name huis1@huis1.straat.org -setcookie abc

erl2:
	docker -D run --name huis2 -it --rm --dns-search=straat.org --net=lokaal -h huis2 --network-alias=huis2.straat.org lrutten/erlang erl -name huis2@huis2.straat.org -setcookie abc

bash1:
	docker -D run --name huis1 -it --rm --dns-search=straat.org --net=lokaal -h huis1 --network-alias=huis1.straat.org lrutten/erlang /bin/bash

bash2:
	docker -D run --name huis2 -it --rm --dns-search=straat.org --net=lokaal -h huis2 --network-alias=huis2.straat.org lrutten/erlang /bin/bash

stop1:
	docker stop huis1

stop2:
	docker stop huis2


images:
	docker images
~~~~


# `tellers` test met een Cowboy app

In deze test is een Cowboy app opgenomen in de `Dockerfile`.
De container wordt tweemaal gestart:

~~~~
make erl1
make erl2
~~~~

En elk huis draait de tellerwebapp. Die van `huis1` kan bereikt worden
via `localhost:8080` en die van `huis2` via `localhost:8081`. Elke
container draait interactief en toont de `erl` prompt. Zo wordt de 
ping manueel uitgevoerd:

~~~~
net_adm:ping('teller@huis2').
~~~~

Dit geeft een `pong`. De docker networking zorgt ervoor dat de beide containers via DNS
bereikbaar zijn.

# `tellers2`

In deze versie wordt de `teller` app met Cowboy gestart in 2 containers.
In de release wordt ook de `bootstrap` app gestart.
Deze zorgt voor een automatische clustering.

In `app/teller/config/sys.config` moet voor `bootstrap` de instelling
`multicast` gekozen worden. Anders werkt het niet.

 
~~~~
[
  {teller, []},
  {bootstrap,
    [
       {protocol, multicast}
    ]
  }
].
~~~~

`bootstrap` kiest als defaultwaarde `broadcast` en dit werkt niet.
Het Docker user netwerk heeft een verkeerde instelling voor het broadcastadres.


# `tellers3`

De containers moeten niet meer manueel gestart worden en
worden nu met `docker swarm` gestart.
De Erlang cluster wordt automatisch gemaakt met `bootstrap`.

Hier staat meer uitleg:

* [tellers3/](tellers3/)

# `tellers4`

De containers moeten niet meer manueel gestart worden en
worden nu met `docker swarm` gestart.
De Erlang cluster wordt automatisch gemaakt met `bootstrap`.

En als extra is de `taximapa` app bijgevoegd.

Hier staat meer uitleg:

* [tellers4/](tellers4/)


# Links


Deze links zijn nuttig:

* [https://docs.docker.com/engine/userguide/networking/](https://docs.docker.com/engine/userguide/networking/)
* [https://docs.docker.com/engine/swarm/](https://docs.docker.com/engine/swarm/)
* [https://docs.docker.com/engine/userguide/networking/configure-dns/](https://docs.docker.com/engine/userguide/networking/configure-dns/)
* [https://docs.docker.com/engine/userguide/networking/default_network/configure-dns/](https://docs.docker.com/engine/userguide/networking/default_network/configure-dns/)









