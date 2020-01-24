-module(node).

-export([loop/3, send_results/2]).

% Funcion que inicializa al nodo que hara de mapper
loop(List, PidMaster, NodeNumber) ->
	receive
		{ startmap, IdParent, Fmap } ->
			KeyValues = Fmap(List, NodeNumber),
			send_results(KeyValues, IdParent),
			loop(List, PidMaster, NodeNumber)
	end.

% Funcion que manda resultados al dealer
send_results([], IdParent) ->
	IdParent ! { mapper_end, 'end' };
send_results([HeadList | TailList], IdParent) ->
	IdParent ! { mapper_results, HeadList },
	send_results(TailList, IdParent).
