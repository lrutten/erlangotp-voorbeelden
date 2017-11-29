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

