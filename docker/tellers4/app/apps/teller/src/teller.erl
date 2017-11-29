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
   % Ping alles nodes uit .hosts.erlang
   NodeList = net_adm:world(),
   io:format("nodelist ~p~n", [NodeList]),

   % Vraag enkele pids van entiteiten op.
   P1 = taximapa:getPid("Bert"),
   P2 = taximapa:getPid("Jan"),
   case P2 of
      error ->
         error;
      {ok, Pid} when is_pid(Pid) ->
         io:format("ontvangen Pid is_pid ~p~n", [Pid]),
         Pid ! {bericht},
         ok;
      Pid  ->
         io:format("ontvangen Pid is geen pid ~p~n", [Pid]),
         error
   end,

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
      2000 ->
         loop(Teller + 1)
   end.
