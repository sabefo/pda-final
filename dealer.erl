-module(dealer).

-export([init/4, send_function/2, receive_results/3, check_dictionary/4, send_ends/1]).

% Funcion que inicializa al dealer
init(_Parent, Fmap, Freduce, NodePids) ->
	send_function(NodePids, Fmap),
	Dictionary = receive_results(maps:new(), Freduce, length(NodePids)),
	receive_results(Dictionary, Freduce, 1).

% Funcion que manda end a los reducers una vez que todos los mappers terminan
send_ends([])-> ok;
send_ends([PidHead | PidTail])->
	PidHead ! 'end',
	send_ends(PidTail).

% Funcion que manda Fmap a todas las listas
send_function([], _) -> ok;
send_function([HeadPid | TailPids], Fmap) ->
	HeadPid ! { startmap, self(), Fmap },
	send_function(TailPids, Fmap).

% Funcion que recibe los mensajes de los nodos y de los reducers
receive_results(Dictionary, _, 0) -> 
	io:format("Dictionary quedo asi = ~p~n",[Dictionary]),
	send_ends(maps:values(Dictionary)),
	Dictionary;
receive_results(Dictionary, Freduce, NLeft) ->
	receive
		{ mapper_end, 'end' } ->
			io:format("Recibi END del MAPPER ~n"),
			receive_results(Dictionary, Freduce, NLeft - 1);
		{ mapper_results, { Key, Value } } ->
			NewDictionary = check_dictionary(Key, Value, Dictionary, Freduce),
			receive_results(NewDictionary, Freduce, NLeft);
		{ reducer_results, { Key, Value } } ->
			io:format("Recibi K = ~p~n",[Key]),
			io:format("Recibi V = ~p~n",[Value]),
			receive_results(Dictionary, Freduce, 1)
	end.

% Funcion que recibe un diccionario y revisa si ya cuenta con un dato o no, y despues llama a los reducers
check_dictionary(Key, Value, Dictionary, Freduce) ->
	Boolean = maps:is_key(Key, Dictionary),
	if Boolean =:= true ->
		Pid = maps:get(Key, Dictionary),
		Pid ! { newValue, Value },
		io:format("Grite al pid este = ~p~n",[Pid]),
		Dictionary;
	true ->
		Me = self(),
		Pid = spawn(fun() -> reducer:init(Me, Freduce, Key, Value) end),
		Pid ! { newValue, Value },
		maps:put(Key, Pid, Dictionary)
	end.
