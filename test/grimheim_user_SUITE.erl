-module(grimheim_user_SUITE).

-include_lib("common_test/include/ct.hrl").

-export([init_per_suite/1, end_per_suite/1, all/0]).

all() -> [].

init_per_suite(Config) ->
    Priv = ?config(priv_dir, Config),
    application:set_env(mnesia, dir, Priv),
    grimheim_user:install([node()]),
    application:ensure_all_started(grimheim_login),
    Config.

end_per_suite(_Config) ->
    application:stop(mnesia),
    ok.
