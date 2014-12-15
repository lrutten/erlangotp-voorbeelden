-module(teller).

-export([start/0, stop/0]).

-export([init/0, loop/2, get/0, reset/0, getlist/0, format_utc_timestamp/0]).

start() ->
   Pid = spawn(?MODULE, init, []),
   register(teller, Pid),
   {ok, Pid}.

stop() ->
   teller ! {stop}.

init() ->
   loop(0, []),
   {ok, []}.

get() ->
   teller ! {get, self()},
   receive
      Result -> Result
   end.

reset() ->
   teller ! {reset},
   ok.

getlist() ->
   teller ! {getlist, self()},
   receive
      Result -> Result
   end.
   
loop(Teller, List) ->
   receive
      {get, From} ->
         From ! Teller,
         List2 = [{format_utc_timestamp(), Teller} | List],
         loop(Teller, List2);
      {reset} ->
         loop(0, List);
      {getlist, From} ->
         From ! List,
         loop(Teller, List);
      {stop} ->
         ok;
      _ ->
         loop(Teller, List)
   after
      1000 ->
         loop(Teller + 1, List)
   end.

   
   
format_utc_timestamp() ->
   TS = {_,_,Micro} = os:timestamp(),
   {{Year,Month,Day},{Hour,Minute,Second}} = 
	calendar:now_to_universal_time(TS),
   Mstr = element(Month,{"Jan","Feb","Mar","Apr","May","Jun","Jul",
			  "Aug","Sep","Oct","Nov","Dec"}),
   list_to_binary(io_lib:format("~2w ~s ~4w ~2w:~2..0w:~2..0w.~6..0w",
		  [Day,Mstr,Year,Hour,Minute,Second,Micro])).
		  
		  
