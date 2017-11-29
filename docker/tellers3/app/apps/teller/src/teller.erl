-module(teller).

-export([start/0, stop/0]).

-export([init/0, loop/1, get/0]).

start() ->
    io:format("teller:start()~n"),
    Pid = spawn(?MODULE, init, []),
    register(teller, Pid),
    {ok, Pid}.

stop() ->
    teller ! {stop}.

init() ->
    bootstrap:monitor_nodes(true),
    loop(0),
    {ok, []}.

get() ->
    teller ! {get, self()},
    receive
       Result -> Result
    end.

loop(Teller) ->
   % connect to nodes is .hosts.erlang
   NodeList = net_adm:world(),
   io:format("nodelist ~p~n", [NodeList]),

   receive
      {get, From} ->
         From ! Teller,
         loop(Teller);
      {stop} ->
         ok;
      M ->
         io:format("message ~p~n", [M]),
         loop(Teller)
   after
      1000 ->
         loop(Teller + 1)
   end.
