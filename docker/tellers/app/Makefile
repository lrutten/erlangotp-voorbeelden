deps:
	rebar3 deps

patch:
	sed -i '31s/dict()/dict:dict()/' _build/default/lib/eunit_formatters/src/eunit_progress.erl

compile:
	rebar3 compile

release:
	rebar3 release

clean:
	rebar3 clean

clean-all: clean
	rm -Rvf _build
	rm -vf rebar.lock

tree:
	rebar3 tree

run:
	_build/default/rel/teller/bin/teller console

