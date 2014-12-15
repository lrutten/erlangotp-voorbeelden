-module(over_handler).
-behavior(cowboy_http_handler).
 
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
 
init(_Type, Req, _Opts) ->
   {ok, Req, undefined_state}.
 
handle(Req, State) ->
   {Url, _}    = cowboy_req:url(Req),
   {Method, _} = cowboy_req:method(Req),
   {Host, _}   = cowboy_req:host(Req),
   {Port, _}   = cowboy_req:port(Req),
   {Path, _}   = cowboy_req:path(Req),
   {Peer, _}   = cowboy_req:peer(Req),

   io:format("Method ~p~n", [Method]),
   
   ReqProps =
   [
      {<<"url">>,    Url},
      {<<"method">>, Method},
      {<<"host">>,   Host},
      {<<"port">>,   Port},
      {<<"path">>,   Path},
      {<<"peer">>,   Peer}
   ],
   {ok, Body} = over_dtl:render([{<<"req">>, ReqProps}]),
   Headers = [{<<"content-type">>, <<"text/html">>}],
   {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
   {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

