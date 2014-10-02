-module(simpeleteller_app).
-behavior(application).
 
-export([start/2]).
-export([stop/1]).
 
start(_Type, _Args) ->
    simpeleteller:start().
 
stop(_State) ->
    ok.


