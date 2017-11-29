%%%-------------------------------------------------------------------
%% @doc taximapa top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(taximapa).

-export([start/0]).
-export([init/0, getPid/1]).
-export([loop/1]).

%% API
% Vraag de naam op en geef de Pid terug.
getPid(Naam) ->
   io:format("getPid/1 ~p ~p~n", [Naam, nodes()]),
   getPid(Naam, nodes()).

%% lokale hulpfunctie
% Vraag de naam op bij de eerste node in de lijst.
getPid(Naam, []) ->
   % Er zijn geen nodes meer.
   io:format("getPid/2 ~p [] error~n", [Naam]),
   {error};
getPid(Naam, [Node|RestNodes]) ->
   % Stuur een bericht naar de node en wacht.
   io:format("getPid/2 ~p node ~p~n", [Naam, Node]),
   Ref = make_ref(),
   {taximapa, Node} ! {get, Ref, Naam, self()},
   receive
      {naam, Ref, Pid} ->
         case Pid of
            {error} ->
               % De ondervraagde node weet het niet.
               io:format("getPid/2 rec error ~p~n", [Pid]),
               % Vraag het aan de volgende node.
               getPid(Naam, RestNodes);
            _ ->
               io:format("getPid/2 rec ok ~p~n", [Pid]),
               Pid
         end;
      _ ->
         {error}
   end.

% De entiteiten worden verdeeld over 2 nodes.
entiteiten() ->
   [
      {'teller@host-1', auto,    "BMW",     []},
      {'teller@host-1', auto,    "VW",      []},
      {'teller@host-1', persoon, "Jan",     
         [
            {kinderen, ["Piet", "Joris"]}
         ]
      },
      {'teller@host-1', persoon, "Piet",    []},
      {'teller@host-1', persoon, "Joris",   []},
      
      {'teller@host-2', auto,    "Skoda",   []},
      {'teller@host-2', auto,    "Ford",    []},
      {'teller@host-2', persoon, "Greet",   []},
      {'teller@host-2', persoon, "Korneel", []},
      {'teller@host-2', persoon, "Dirk",    []}
   ].

% Maak een nieuwe lijst met enkel de lokale entiteiten.
lokale_entiteiten() ->
   [
      {Node, Mod, Naam, Props}
      ||
      {Node, Mod, Naam, Props} <- entiteiten(),
      Node == node()
   ].

% Zoek de pid van een lokale naam.
pidVan([], _Naam) ->
   {error};
pidVan([{Node, _Type, Naam, _Props, Pid}|_Rest], Naam) ->
   {ok, Pid};
pidVan([{_Node, _Type, _Naam2, _Props, _Pid}|Rest], Naam) ->
   pidVan(Rest, Naam).

% Start alle processen voor de lokale entiteiten.
% Het resultaat is een nieuwe lijst met in elke tuple
% de pid als laatste element.
maak_lokale_pids() ->
   [
      {Node, Mod, Naam, Props, Mod:start(Props)}
      ||
      {Node, Mod, Naam, Props} <- lokale_entiteiten()
   ].

% Start de taximapa applicatie.
start() ->
   Pid = spawn(taximapa, init, []),
   register(taximapa,Pid),
   {ok, Pid}.

init() ->
   loop(maak_lokale_pids()).

% Dit is de loop van taximapa.
% Ents bevat enkel de lijst van de lokale entiteiten.
loop(Ents) ->
   io:format("local entities ~p~n", [Ents]),
   receive
      {get, Ref, Naam, Sender} ->
         io:format("taximapa {get naam ~p Sender ~p}~n", [Naam, Sender]),
         io:format("taximapa local entities ~p~n", [Ents]),
         Sender ! {naam, Ref, pidVan(Ents, Naam)},
         loop(Ents);
      _ ->
          io:format("hallo~p~n", [Ents]),
          loop(Ents)
   end.
