%%%-------------------------------------------------------------------
%% @doc persoon.
%% @end
%%%-------------------------------------------------------------------

-module(persoon).


%% API
-export([start/1]).
-export([init/1]).

   
start(Props) ->
   Pid = spawn(persoon, init, [Props]),
   Pid.

init(Props) ->
   loop(Props).

loop(Props) ->
   receive
      _ ->
          io:format("persoon:hallo ~p~n", [Props]),
          loop(Props)
   end.
