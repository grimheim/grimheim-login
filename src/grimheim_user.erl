-module(grimheim_user).

-include("include/grimheim_user.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

-export([install/1, create_user/2]).

-spec install([node()]) -> any().
install(Nodes) ->
    ok = mnesia:create_schema(Nodes),
    rpc:multicall(Nodes, application, start, [mnesia]),
    mnesia:create_table(grimheim_user,
                        [{attributes, record_info(fields, grimheim_user)},
                         {index, [#grimheim_user.name,
                                  #grimheim_user.email
                                 ]},
                         {disc_copies, Nodes}]),
    rpc:multicall(Nodes, application, stop, [mnesia]).

-spec create_user(string(), string()) -> {ok, grimheim_user()}
                                         | {error, user_exists | email_exists}.
create_user(Username, Email) ->
    Match = ets:fun2ms(
              fun(#grimheim_user{name=N}) when N =:= Username ->
                      user_exists;
                 (#grimheim_user{email=E}) when E =:= Email ->
                      email_exists
              end),
    F = fun() ->
                case mnesia:select(grimheim_user, Match) of
                    [] ->
                        UUID = uuid:get_v4(),
                        User = #grimheim_user{
                                        id = UUID,
                                        name = Username,
                                        email = Email
                                       },
                        ok = mnesia:write(User),
                        {ok, User};
                    [Error] -> {error, Error}
                end
        end,
    mnesia:activity(transaction, F).
