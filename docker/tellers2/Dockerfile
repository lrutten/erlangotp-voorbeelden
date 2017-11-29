FROM erlang:19.1.6

RUN apt-get update
RUN apt-get install -y dnsutils

COPY app app
WORKDIR /app
RUN rebar3 deps
RUN rebar3 compile
RUN rebar3 release

EXPOSE 4000-50000

CMD /app/_build/default/rel/teller/bin/teller console
