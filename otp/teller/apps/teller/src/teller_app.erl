-module(teller_app).
-behavior(application).
 
-export([start/2]).
-export([stop/1]).
 
start(_Type, _Args) ->
    teller:start().
 
stop(_State) ->
    ok.


