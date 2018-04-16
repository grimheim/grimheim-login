-module(grimheim_user).

-export([install/1]).

-record(grimheim_user, { id       :: string(),
                         name     :: string(),
                         password :: string() | undefined,
                         salt     :: string() | undefined,
                         reset    :: string() | undefined
                       }).
-type grimheim_user() :: #grimheim_user{}.


install(Nodes) ->
    ok = mnesia:create_schema(Nodes),
    rpc:multicall(Nodes, application, start, [mnesia]),
    mnesia:create_table(grimheim_user,
                        [{attributes, record_info(fields, grimheim_user)},
                         {index, [#grimheim_user.name]},
                         {disc_copies, Nodes}]),
    rpc:multicall(Nodes, application, stop, [mnesia]).
