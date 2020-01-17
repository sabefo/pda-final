-module(dealer).

-export([init/4]).

% mapreduce, Parent, Fmap, Freduce
init(Parent, Fmap, Freduce, NodePids) ->
	io:format("Dealer con: ~p~n",[NodePids]).
