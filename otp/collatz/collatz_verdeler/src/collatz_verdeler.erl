-module(collatz_verdeler).

-export([start/0, stop/0]).

-export([init/0, loop/0]).

start() ->
    Pid = spawn(?MODULE, init, []),
    register(collatz_verdeler, Pid),
    {ok, Pid}.

stop() ->
    collatz_verdeler ! {stop}.

init() ->
    bootstrap:monitor_nodes(true),
    loop(),
    {ok, []}.

loop() ->
   receive
      {stop} ->
         ok;
      {bootstrap, {nodeup, Node}} ->
         io:format("nodeup ~p~n", [Node]),
         herverdeel(nodes()),
         loop();
      {bootstrap, {nodedown, Node, Reason}} ->
         io:format("nodedown ~p ~p~n", [Node, Reason]),
         herverdeel(nodes()),
         loop();
      M ->
         io:format("onbekend bericht ~p~n", [M]),
         loop()
   end.


% lege lijst
herverdeel([]) ->
   io:format("herverdeel geen acties~n");
% 1 knooppunt
herverdeel([Node]) ->
   io:format("herverdeel 1 node ~p~n", [Node]),
   Pid = {collatz, Node},
   Pid ! {naar, Pid};
% 2 of meerdere knoopunten
herverdeel(Nodes) ->
   io:format("herverdeel n nodes ~p~n", [Nodes]),
   io:format("   node ~p~n", [node()]),
   herverdeel_stap(Nodes),
   % sluit de ring
   [First|_] = Nodes,
   Last = lists:last(Nodes),
   {collatz, First} ! {naar, {collatz, Last}}.

% rijg de knoopunten aan elkaar
herverdeel_stap([A|[B]]) ->
   {collatz, B} ! {naar, {collatz, A}};
herverdeel_stap([A|[B|Rest]]) ->
   {collatz, B} ! {naar, {collatz, A}},
   herverdeel([B|Rest]).
   
