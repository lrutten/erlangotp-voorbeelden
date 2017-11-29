%%%-------------------------------------------------------------------
%% @doc auto.
%% @end
%%%-------------------------------------------------------------------

-module(auto).


%% API
-export([start/1]).
-export([init/1]).

   
start(Props) ->
   Pid = spawn(auto, init, [Props]),
   Pid.

init(Props) ->
   loop(Props).

loop(Props) ->
   receive
      _ ->
          io:format("auto:hallo ~p~n", [Props]),
          loop(Props)
   end.
