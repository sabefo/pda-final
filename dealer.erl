-module(dealer).

-export([init/4, send_function/2, receive_results/3, check_dictionary/4]).

% mapreduce, Parent, Fmap, Freduce
init(Parent, Fmap, Freduce, NodePids) ->
	send_function(NodePids, Fmap),
	receive_results(maps:new(), Freduce, length(NodePids)),
	io:format("A recolectar mensajes de KV ~n"),
	receive_results(maps:new(), Freduce, 1).

send_function([], _) -> ok;
send_function([HeadPid | TailPids], Fmap) ->
	HeadPid ! { startmap, self(), Fmap },
	send_function(TailPids, Fmap).

receive_results(Dictionary, _, 0) -> 
	io:format("Dictionary quedo asi = ~p~n",[Dictionary]),
	Dictionary;
receive_results(Dictionary, Freduce, NLeft) ->
	io:format("ESPERANDO MENSAJES ~n"),
	receive
		{ mapper_end, 'end' } ->
			io:format("Recibi ENDS del MAPPER ~n"),
			receive_results(Dictionary, Freduce, NLeft - 1);
		{ mapper_results, { Key, Value } } ->
			NewDictionary = check_dictionary(Key, Value, Dictionary, Freduce),
			receive_results(NewDictionary, Freduce, NLeft);
		{ reducer_results, { Key, Value } } ->
			io:format("Recibi K = ~p~n",[Key]),
			io:format("Recibi V = ~p~n",[Value])
	end.

check_dictionary(Key, Value, Dictionary, Freduce) ->
	Boolean = maps:is_key(Key, Dictionary),
	if Boolean =:= true ->
		Pid = maps:get(Key, Dictionary),
		Pid ! { newValue, Value },
		io:format("Grite al pid este = ~p~n",[Pid]),
		Dictionary;
	true ->
		Pid = spawn(fun() -> reducer:init(self(), Freduce, Key, Value) end),
		maps:put(Key, Pid, Dictionary)
	end.
