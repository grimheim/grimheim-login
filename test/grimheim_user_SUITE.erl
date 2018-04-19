-module(grimheim_user_SUITE).

-include("include/grimheim_user.hrl").
-include_lib("common_test/include/ct.hrl").

-export([init_per_suite/1, end_per_suite/1, all/0]).
-export([create_user/1]).

all() -> [create_user].

init_per_suite(Config) ->
    Priv = ?config(priv_dir, Config),
    application:set_env(mnesia, dir, Priv),
    grimheim_user:install([node()]),
    application:ensure_all_started(grimheim_login),
    Config.

end_per_suite(_Config) ->
    application:stop(mnesia),
    application:stop(grimheim_login),
    ok.

create_user(_Config) ->
    Username = "bob",
    Email = "bob@bob.com",
    {ok, #grimheim_user{name = Username, email = Email}} =
        grimheim_user:create_user(Username, Email),
    {error, user_exists} = grimheim_user:create_user(Username, Email),
    {error, email_exists} = grimheim_user:create_user("not a user", Email).
