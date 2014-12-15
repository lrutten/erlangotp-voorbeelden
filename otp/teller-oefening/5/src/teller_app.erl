-module(teller_app).
-behavior(application).
 
-export([start/2]).
-export([stop/1]).
 
start(_Type, _Args) ->
   Dispatch = cowboy_router:compile(
   [
      %% {URIHost, list({URIPath, Handler, Opts})}
      {'_', % host
         [
            % static information
            {
               "/res/[...]",  % path 
               cowboy_static, % handler
               {              % options
                  priv_dir, teller, "",
                  [{mimetypes, cow_mimetypes, all}]
               }
            },
            % reset POST action
            {"/reset", reset_handler, []},
            
            % extra pagina's
            {"/over",       over_handler, []},
            {"/statistiek", statistiek_handler, []},
            
            % main page
            {'_', teller_handler, []}
         ]
      }
   ]),

   %% Name, NbAcceptors, TransOpts, ProtoOpts
   cowboy:start_http(my_http_listener, 100,
       [{port, 8080}],
       [{env, [{dispatch, Dispatch}]}]
   ),
   teller:start().
 
stop(_State) ->
    ok.


