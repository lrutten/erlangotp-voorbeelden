-module(reset_handler).
-behavior(cowboy_http_handler).
 
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
 
init(_Type, Req, _Opts) ->
   {ok, Req, undefined_state}.
 
handle(Req, State) ->
   io:format("reset requestobject ~p~n", [Req]),
   io:format("      state ~p~n", [State]),
   
   teller:reset(),

   % Antwoord met een redirect
   Req2 = cowboy_req:reply(302, [{<<"Location">>, <<"/">>}],
       <<"Redirecting with Header">>, Req),
   
   io:format("      requestobject2 ~p~n", [Req2]),
   {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

