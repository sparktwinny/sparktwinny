%%%-------------------------------------------------------------------
%%% @author psw
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 12월 2015 오후 8:37
%%%-------------------------------------------------------------------
-module(mon_reloader).
-author("psw").

-include_lib("kernel/include/file.hrl").
%% API
-export([start/0,loop/1,reload/1]).

start()->
  io:format("Reloading start~n"),


  Pid=spawn(mon_reloader,loop,[erlang:localtime()]),
  timer:send_interval(timer:seconds(1),Pid,check).


loop(From)->
  receive
    check ->
      %%io:format("checking updates...~n"),
      To=erlang:localtime(),
      [check(From,To,Module,Filename)
      ||{Module,Filename}<-code:all_loaded(),is_list(Filename)],
        loop(To);
    update->
      ?MODULE:loop(from);
    Other->
      io:format("~p~n",[Other]),
      loop(From)


  end.

check(From,To,Module,Filename)->
  case file:read_file_info(Filename) of
    {ok,#file_info{mtime=MTime}} when MTime >=From,MTime< To ->
    reload(Module);
    _ ->
      pass
  end.
reload(Module) ->
  io:format("Reloading ~p ...",[Module]),
  code:purge(Module),
  code:load_file(Module),
  io:format(" ok. ~n").