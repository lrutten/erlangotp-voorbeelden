-module(teller_app).
-behavior(application).
 
-export([start/2]).
-export([stop/1]).
 
start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
        %% {URIHost, list({URIPath, Handler, Opts})}
        {'_', [{'_', teller_handler, []}]}
    ]),
    %% Name, NbAcceptors, TransOpts, ProtoOpts
    cowboy:start_http(my_http_listener, 100,
        [{port, 8080}],
        [{env, [{dispatch, Dispatch}]}]
    ),

    M = code:which(index_dtl),
    io:format("module path ~p~n", [M]),
    M2 = code:which(cowboy),
    io:format("module path ~p~n", [M2]),

    teller:start().
 
stop(_State) ->
    ok.


