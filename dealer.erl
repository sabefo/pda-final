-module(dealer).

-export([init/4, send_function/2, receive_results/3, check_dictionary/4]).

% mapreduce, Parent, Fmap, Freduce
init(Parent, Fmap, Freduce, NodePids) ->
	send_function(NodePids, Fmap),
	receive_results(maps:new(), Freduce, length(NodePids)),
	io:format("A recolectar mensajes de KV ~n").
	%loop

send_function([], _) -> ok;
send_function([HeadPid | TailPids], Fmap) ->
	HeadPid ! { startmap, self(), Fmap },
	send_function(TailPids, Fmap).

receive_results(Dictionary, _, 0) -> 
	io:format("Dictionary es = ~p~n",[Dictionary]),
	Dictionary;
receive_results(Dictionary, Freduce, NLeft) ->
	receive
		'end' ->
			io:format("Recibi ENDS ~n"),
			receive_results(Dictionary, Freduce, NLeft - 1);
		{ Key, Value } ->
			io:format("Recibi K = ~p~n",[Key]),
			io:format("Recibi V = ~p~n",[Value]),
			NewDictionary = check_dictionary(Key, Value, Dictionary, Freduce),
			io:format("Dictionary es = ~p~n",[NewDictionary]),
			% REVISO DIC, SI ESTA, MANDO AL MISMO REDUCER, SINO CREO UNO Y RECUERDO SU PID EN EL DIC Y MANDO AL NUEVO REDUCER
			receive_results(NewDictionary, Freduce, NLeft)
	end.


% {IdParent, Freduce, Clave, Valor}
check_dictionary(Key, Value, Dictionary, Freduce) ->
	Boolean = maps:is_key(Key, Dictionary),
	if Boolean =:= true ->
		Pid = maps:get(Key, Dictionary),
		io:format("SI LO TENGO, GRITO AL PID = ~p~n",[Pid]),
		Dictionary;
	true ->
		Pid = spawn(fun() -> reducer:init(self(), Freduce, Key, Value) end),
		NewDictionary = maps:put(Key, Pid, Dictionary),
		NewDictionary
	end.

% check_dictionary(Key, Value, Dictionary, Freduce) ->
% 	io:format("Vamos a buscar KEY, que es = ~p~n",[Key]),
% 	error =:= maps:find(Key, Dictionary),
% 	io:format("Vamos a buscar en Dictionary, que es = ~p~n",[Dictionary]),
% 	io:format("No lo tengo, agrego y mando esto al reducer ~n"),
% 	Pid = spawn(fun() -> reducer:init(self(), Freduce, Key, Value) end),
% 	NewDictionary = maps:put(Key, Pid, Dictionary),
% 	NewDictionary;
% check_dictionary(Key, Value, Dictionary, Freduce) ->
% 	{ ok, Pid } = maps:find(Key, Dictionary),
% 	io:format("Si lo tengo, mando esto al reducer ~n"),
% 	io:format("PID ES = ~p~n",[Pid]),
% 	Dictionary.
