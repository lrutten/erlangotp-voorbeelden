# `teller3`

In deze versie wordt de `teller` app gestart in 2 containers in swarm mode.

In de release wordt ook de `bootstrap` app gestart.
Deze zorgt normaal gezien voor de automatische clustering maar vermits
in swarm mode een ander type netwerk wordt gebruikt werken noch broadcast noch multicast.
Het netwerk is nu van het `overlay` type in plaats van `bridge`. Dankzij het 
`overlay` type is het mogelijk om de containers in verschillende PC's te plaatsen.

Maar de nadeel is nu het feit dat de `bootstrap` application niet meer werkt.
De voorlopige oplossing is een manuele nodeconfiguratie.
Als je in de homedirectory (`/root` dus) het verborgen bestand `.hosts.erlang` plaatst,
dan kunnen de nodes elkaar gemakkelijker vinden. Tijdens de build wordt de lijst van nodes
naar de image gekopieerd. De `Dockerfile` ziet er nu zo uit:

~~~~
FROM erlang:20.1.5

RUN apt-get update
RUN apt-get install -y dnsutils

COPY hosts.erlang /root/.hosts.erlang
COPY app app
WORKDIR /app
RUN rebar3 deps
RUN rebar3 compile
RUN rebar3 release

EXPOSE 4000-55000

CMD /app/_build/default/rel/teller/bin/teller foreground
~~~~

De eerste `COPY` hierboven kopieert de lijst met de nodes.
`.hosts.erlang` heeft deze inhoud:

~~~~
'host-1'.
'host-2'.
~~~~

De build wordt uitgevoerd:

~~~~
docker build -t lrutten/erlang-tellers3 .
~~~~


Het netwerk wordt zo gemaakt:

~~~~
docker network create \
    --driver overlay \
    --subnet 172.21.0.0/16 labo
~~~~


De service wordt zo gestart:

~~~~
$ docker service create \
    --replicas 2 \
    --network labo \
    --host=host-1:172.21.0.3 \
    --host=host-2:172.21.0.4 \
    --name teller \
    --hostname="host-{{.Task.Slot}}" \
    --publish 80:8080 lrutten/erlang-tellers3
~~~~

Er worden 2 replica's gemaakt die op dezelfde node draaien (als er maar 1 node is).
Met `--host` worden de IP adressen van alle containers expliciet vermeld.
Deze adressen komen telkens in `/etc/hosts` in elke container terecht.
Dit is nodig om de hostnamen via DNS te kunnen bereiken.
Anders gaan de Erlang nodes elkaar niet kunnen bereiken.

Alle containers hebben een hostname `host-1`, `host-2`, ...
en de bijbehorende IP adressen starten bij 172.21.0.3.

Vermits we dit experiment op slechts één PC uitvoeren, draaien beide replica's
als een container op deze PC. Dat zien we zo:

~~~~
$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS               NAMES
6c9fad6e3760        lrutten/erlang:latest   "/bin/sh -c '/app/..."   18 seconds ago      Up 12 seconds       4000-50000/tcp      teller.2.n6ojfpwyfjxw6kkrit2lh8f78
6600583e6d8f        lrutten/erlang:latest   "/bin/sh -c '/app/..."   18 seconds ago      Up 12 seconds       4000-50000/tcp      teller.1.h948zk3fmpjgg91qv18lo6exn
~~~~

De containers draaien in de achtergrond. En zo maak je een `bash` prompt:

~~~~
$ docker exec -ti 660 /bin/bash
root@host-1:/app# 
~~~~

Beide containers kunnen elkaar bereiken via DNS:

~~~~
root@host-1:/app# ping host-1
root@host-1:/app# ping host-2
~~~~

De `ping` commando's geven respectievelijk de IP adressen `172.21.0.3` en `172.21.0.3`.
De `bash `prompt hierboven is die van `host-1`. Nu hebben we de Erlang prompt nodig.
Start een extra Erlang `erl` prompt:

~~~~
root@host-1:~# erl -sname tester -setcookie teller_cookie
Erlang/OTP 20 [erts-9.1.4] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:10] [hipe] [kernel-poll:false]

Eshell V9.1.4  (abort with ^G)
(tester@host-1)1> node().
'tester@host-1'
(tester@host-1)2> nodes().
['teller@host-2','teller@host-1']
(tester@host-1)3> 
~~~~

De andere nodes zitten meteen in de cluster. Dit wordt mogelijk gemaakt door `/root/.hosts.erlang`.
Dit betekent dat er geen extra pings nodig zijn.

Hier zijn nog de stappen om de `erl` prompt van de teller te pakken te krijgen.
Type eerst `^G`.

~~~~
^G
User switch command
 --> j
   1* {shell,start,[init]}
 --> r 'teller@host-1'
 --> j
   1  {shell,start,[init]}
   2* {'teller@host-1',shell,start,[]}
 --> c 2
Eshell V9.1.4  (abort with ^G)
(teller@host-1)1> 
(teller@host-1)1> node().
'teller@host-1'
(teller@host-1)2> nodes().
['teller@host-2','tester@host-1']
(teller@host-1)3> net_adm:world().
['teller@host-1','tester@host-1','teller@host-2']
(teller@host-1)4>
~~~~

Er verschijnt een andere prompt (`-->`) van waaruit je een remote connectie kan maken.
Nu kan je de teller opvragen:

~~~~
(teller@host-1)5> whereis(teller).
<0.504.0>
(teller@host-1)6> teller:get().   
3669
(teller@host-1)7> teller:get().
3670
~~~~

