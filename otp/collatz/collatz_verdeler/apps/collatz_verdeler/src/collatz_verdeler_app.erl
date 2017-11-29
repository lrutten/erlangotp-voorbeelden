-module(collatz_verdeler_app).
-behavior(application).
 
-export([start/2]).
-export([stop/1]).
 
start(_Type, _Args) ->
    collatz_verdeler:start().
 
stop(_State) ->
    ok.


