-module(teller_handler).
-behavior(cowboy_http_handler).
 
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
 
init(_Type, Req, _Opts) ->
   {ok, Req, undefined_state}.
 
handle(Req, State) ->
   Teller = teller:get(),     
   Body = [<<"<html>
<head>
        <meta charset=\"utf-8\">
        <title>Teller!</title>
</head>
<body>
  <h1>Teller</h1>
  <p>De tellerwaarde is ">>,  io_lib:format("~p",[Teller]), <<"</p>
  <p>Herlaad om de nieuwe waarde van de teller te zien.</p>
</body>
</html>">>],
    {ok, Req2} = cowboy_req:reply(200, 
      [
        {<<"content-type">>, <<"text/html">>}
      ], Body, Req),
    {ok, Req2, State}.
 
terminate(_Reason, _Req, _State) ->
    ok.

