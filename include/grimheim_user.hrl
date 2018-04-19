-record(grimheim_user, { id       :: binary(),
                         name     :: string(),
                         email    :: string(),
                         password :: string() | undefined,
                         salt     :: string() | undefined,
                         reset    :: string() | undefined
                       }).
-type grimheim_user() :: #grimheim_user{}.
