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

   R1 = inet_res:lookup("tasks.teller", in, a),
   io:format("R1 ~p~n", [R1]),

   %% Geeft een timeout
   %%R2 = inet_res:gethostbyaddr({172,21,0,3}),
   %%io:format("R2 ~p~n", [R2]),
   
   %%R3 = inet_res:gethostbyaddr({172,21,0,4}),
   %%io:format("R3 ~p~n", [R3]),
   
   {ok, Body} = index_dtl:render(
      [
         {waarde, Teller},
         {node, node()},
         {nodes, nodes()}
      ]),
   Headers = [{<<"content-type">>, <<"text/html">>}],
   {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
   {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

