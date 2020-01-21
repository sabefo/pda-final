-module(node).

-export([start/0, loop/3, send_results/2]).

start() -> spawn(node, init, []).

loop(List, PidMaster, NodeNumber) ->
	receive
		{ startmap, IdParent, Fmap } ->
			% KeyValues = Fmap(List, NodeNumber),
			% send_results(KeyValues, IdParent),
			send_results(List, IdParent),
			loop(List, PidMaster, NodeNumber)
	end.
	% loop(List, PidMaster, NodeNumber)

send_results([], IdParent) ->
	IdParent ! 'end';
send_results([HeadList | TailList], IdParent) ->
	IdParent ! HeadList,
	send_results(TailList, IdParent).
% Contienen un trozo de información representado como una lista. Tras ser creados quedan a la espera de recibir un mensaje (startmap, IdParent, Fmap) que indica que deben aplicar la función Fmap a cada elemento de su lista, pasándole además la posición del nodo (este valor se usa rara vez). Cada vez que aplica la función a un elemento se obtiene una lista L de elementos de la forma {Clave, Valor}. El nodo le envía al IdParent tantos mensajes como elementos tenga la lista L. Cuando ha aplicado la función a todos los elementos de la lista, envía a IdParent el mensaje end. En este momento el nodo, que ha terminado su tarea, vuelve a pasar a la espera de recibir un nuevo mensaje (startmap, IdParent, Fmap).


% EJEMPLO DE COMO MANDAR UNA FUNCION
% P ! {mapreduce, self(), fun(X)-> X + 1 end, 1}.

% PREGUNTAS
% los crea el master y despues reciben la info?
