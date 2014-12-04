-module(eventteller).

-export([start/0, stop/0, timerevent_handler/0]).

-export([init/0, loop/1, get/0]).

% De start van deze module.
start() ->
    Pid = spawn(?MODULE, init, []),
    register(eventteller, Pid),
    {ok, Pid}.

% Stop het tellerproces.
stop() ->
    eventteller ! {stop}.

% Start van het tellerproces.
init() ->
    starttimer(1000),
    loop(0),
    {ok, []}.

% Vraag de waarde van de teller op.
get() ->
    eventteller ! {get, self()},
    receive
       Result -> Result
    end.

% Dit is de loop met de toestand van de teller.
% De after rubriek is nu weggelaten.
loop(Teller) ->
   io:format("teller ~p~n", [Teller]),
   receive
      {get, From} ->
         From ! Teller,
         loop(Teller);
      {timerevent} ->
         io:format("timerevent received~n"),
         starttimer(1000),
         loop(Teller + 1);
      {stop} ->
         ok;
      _ ->
         loop(Teller)
   end.

% Handler die door de event_manager wordt gestart
% na afloop van de wachttijd.
timerevent_handler() ->
   io:format("timerevent_handler~n"),
   eventteller ! {timerevent},
   ok.

% Start een timer.
%   Delay: de te wachten tijd in ms
starttimer(Delay) ->
   io:format("starttimer~n"),
   event_manager:postincr({Delay, ?MODULE, timerevent_handler, []}).


