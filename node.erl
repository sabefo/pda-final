-module(node).

-export([start/0, loop/3]).

start() -> spawn(node, init, []).

loop(List, PidMaster, NodeNumber) ->
	io:format("Nodo creado ~n").

	% receive
	% { List, PidMaster, NodeNumber } ->
	% 	loop(List, PidMaster, NodeNumber);
	% % { startmap, IdParent, Fmap } ->
	% 	% Client ! {self(), "New dir: "++Dir1},
	% 	% loop(List, ParentPid, NodeNumber);
	% % {Client, list_dir} ->
	% % 	Client ! {self(), file:list_dir(Dir)},
	% % 	loop(List, NodeNumber);
	% % {Client, {get_file, File}} ->
	% % 	Full = filename:join(Dir, File),
	% % 	Client ! {self(), file:read_file(Full)},
	% % 	loop(List, NodeNumber)
	% end.

% Contienen un trozo de información representado como una lista. Tras ser creados quedan a la espera de recibir un mensaje (startmap, IdParent, Fmap) que indica que deben aplicar la función Fmap a cada elemento de su lista, pasándole además la posición del nodo (este valor se usa rara vez). Cada vez que aplica la función a un elemento se obtiene una lista L de elementos de la forma {Clave, Valor}. El nodo le envía al IdParent tantos mensajes como elementos tenga la lista L. Cuando ha aplicado la función a todos los elementos de la lista, envía a IdParent el mensaje end. En este momento el nodo, que ha terminado su tarea, vuelve a pasar a la espera de recibir un nuevo mensaje (startmap, IdParent, Fmap).


% PREGUNTAS
% para que queremos la posicion del nodo?
% los crea el master y despues reciben la info?
