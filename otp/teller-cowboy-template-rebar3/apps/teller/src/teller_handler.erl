-module(teller_handler).
-behavior(cowboy_http_handler).
 
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
 
init(_Type, Req, _Opts) ->
   {ok, Req, undefined_state}.
 
handle(Req, State) ->
   Teller = teller:get(),

   M = code:which(index_dtl),
   io:format("module index_dtl ~p~n", [M]),
   M2 = code:is_loaded(index_dtl),
   io:format("is_loaded index_dtl ~p~n", [M2]),
   M3 = code:ensure_loaded(index_dtl),
   io:format("ensure_loaded index_dtl ~p~n", [M3]),

   
   {ok, Body} = index_dtl:render([{waarde, Teller}]),
   Headers = [{<<"content-type">>, <<"text/html">>}],
   {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
   {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

