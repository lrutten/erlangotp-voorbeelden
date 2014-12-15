-module(timestamp_handler).
-behavior(cowboy_http_handler).
 
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
 
init(_Type, Req, _Opts) ->
   {ok, Req, undefined_state}.
 
handle(Req, State) ->
   % geef alle variabelen uit de URL weer
   {Bindings, _} = cowboy_req:bindings(Req),
   io:format("Bindings ~p~n", [Bindings]),

   % haal de variabele nr op
   % dit is een binaire string
   {NrStr, _} = cowboy_req:binding(nr, Req),
   io:format("NrStr ~p~n", [NrStr]),
   
   % zet de binaire string om naar list string
   % en dan naar integer
   {Nr, _} = string:to_integer(binary_to_list(NrStr)),
   io:format("Nr ~p~n", [Nr]),

   List = teller:getlist(),
   io:format("List ~p~n", [List]),
   
   El = lists:nth(Nr , List),
   io:format("El ~p~n", [El]),
   
   {ok, Body} = timestamp_dtl:render([{"timestamp", El}]),
   Headers = [{<<"content-type">>, <<"text/html">>}],
   {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
   {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

