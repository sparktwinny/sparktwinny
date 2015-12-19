%%%-------------------------------------------------------------------
%%% @author psw
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 12월 2015 오후 1:05
%%%-------------------------------------------------------------------
-module(mon_app).
-author("psw").

-behaviour(application).

%% Application callbacks
-export([start/2,
  stop/1]).

%%%===================================================================
%%% Application callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application is started using
%% application:start/[1,2], and should start the processes of the
%% application. If the application is structured according to the OTP
%% design principles as a supervision tree, this means starting the
%% top supervisor of the tree.
%%
%% @end
%%--------------------------------------------------------------------
-spec(start(StartType :: normal | {takeover, node()} | {failover, node()},
    StartArgs :: term()) ->
  {ok, pid()} |
  {ok, pid(), State :: term()} |
  {error, Reason :: term()}).

start(_StartType,_StartArgs)->
  ok=application:start(crypto),
  ok=application:start(cowlib),
  ok=application:start(ranch),
  ok=application:start(cowboy),


  Dispatch=cowboy_router:compile([
    {'_',[
      {"/:api/[:what/[:opt]]",mon_http,[]}
    ]}
  ]),

  {ok,_}=cowboy:start_http(http,100,[{port,6060}],[
    {env,[{dispatch,Dispatch}]}
  ]),

  mon_reloader:start(),
  case mon_sup:start_link() of
    {ok,Pid}->
      io:format("start ok~n"),
      {ok,Pid};
    Error->
      Error
  end.


%%start(_StartType,_StartArgs) ->
%%  ok=application:start(crypto),
%%  ok=applcation:start(cowlib),
%%  ok=applcation:start(ranch),
%%  ok=applcation(start(cowboy),
%%
%%
%%    Dispatch=cowboy_router:compile([
%%      {'_',[
%%        {"/hello/world",mon_http,[]}
%%      ]}
%%    ]),
%%
%%    {ok,_}=cowboy:start_http(http,100,[{port,6060}],[
%%      {env,[{dispatch,Dispatch}]}
%%    ]),
%%    case mon_sup:start_link() of
%%      {ok,Pid}->
%%        io:format("start ok~n"),
%%        {ok,Pid};
%%      Error->
%%        Error
%%    end.
%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application has stopped. It
%% is intended to be the opposite of Module:start/2 and should do
%% any necessary cleaning up. The return value is ignored.
%%
%% @end
%%--------------------------------------------------------------------
-spec(stop(State :: term()) -> term()).
stop(_State) ->
  ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
