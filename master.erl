-module(master).

-export([start/2, init/2, split/5, create_nodes/5, create_node/3, loop/1]).
% cd('C:/Users/itestra/Documents/Personal/PDA/Final').

% Funcion que inicia al master con una lista Info llena de {Clave, Valor} y una N para determinar el numero de Nodos
init(Info, N) ->
	if N > length(Info) ->
		io:format("Me pides mas grupos que instancias, solo tengo ~p~n", [length(Info)]);
		true ->
		K = length(Info) div N,
		M = length(Info) rem N,
		if M == 0 ->
			Q = N + 1;
			true -> Q = M
		end,
		List = split(Info, K, Q, 0, N),
		io:format("SplitList ~p~n", [List]),
		start(List, N)
	end.

% Aqui empezamos a crear los nodos despues de recibir la lista la spliteada
start(SplitList, N) -> spawn(fun() -> create_nodes(SplitList, N, [], 0, self()) end).

% Aqui creamos los nodos uno por uno y les mandamos la informacion correspondiente
create_nodes([], _, NodePids, _, _) -> loop(NodePids);
create_nodes([HeadList| TailList], N, NodePids, NodeNumber, MasterPid) ->
	if N > 0 ->
		Pid = spawn(fun() -> create_node(HeadList, MasterPid, NodeNumber + 1) end),
		create_nodes(TailList, N - 1, lists:append([NodePids, [Pid]]), NodeNumber + 1, MasterPid);
		true -> void
	end,
	loop(NodePids).

create_node(List, PidMaster, NodeNumber) ->
	node:loop(List, PidMaster, NodeNumber).

% Loop donde mandamos mensajes al master junto con las funciones Fmap y Freduce
loop(NodePids) ->
	receive
		{ mapreduce, Parent, Fmap, Freduce } -> 
			spawn(fun() -> dealer:init(Parent, Fmap, Freduce, NodePids) end),
			loop(NodePids)
	end.

% Funcion que splitea la lista en N, puede mejorar
split([], _, _, _, _) -> [];
split(L, K, M, C, N) when C == (N - M) ->
	{ A, B } = lists:split((K + 1), L),
	[A | split(B, K, M, C, N)];
split(L, K, M, C, N) ->
	{ A, B } = lists:split(K, L),
	Acum = C + 1,
	[A | split(B, K, M, Acum, N)].
