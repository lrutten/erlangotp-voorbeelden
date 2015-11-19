-module(collatz).

-export([start/0, stop/0]).

-export([init/0, reken/1, loop/1]).

start() ->
    Pid = spawn(?MODULE, init, []),
    register(collatz, Pid),
    {ok, Pid}.

stop() ->
    collatz ! {stop}.

init() ->
    bootstrap:monitor_nodes(true),
    loop(self()),
    {ok, []}.

reken(N) ->
   collatz ! {reken, N, 0, self()},
   receive
      M ->
         io:format("resultaat ~p~n", [M])
   end.

loop(Naar) ->
   receive
      {naar, Nr} ->
         io:format("naar ~p~n", [Nr]),
         loop(Nr);
      {reken, 1, Stappen, Van} ->
         Van ! {stappen, Stappen+1},
         loop(Naar);
      {reken, N, Stappen, Van} ->
         if
            N rem 2 == 0 ->
               Naar ! {reken, N div 2, Stappen+1, Van};
            true ->
               Naar ! {reken, 3*N+1, Stappen+1, Van}
         end,
         loop(Naar);
      {stop} ->
         ok;
      M ->
         io:format("message ~p~n", [M]),
         loop(Naar)
   end.
