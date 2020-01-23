-module(master).

-export([start/2, init/2, split/2, create_nodes/5, create_node/3, loop/1]).
% 'C:/Users/itestra/Documents/Personal/PDA/Final'
% L = [{madrid,34}, {barcelona,21}, {madrid,22}, {barcelona,19}, {teruel,-5}, {teruel, 14}, {madrid,37}, {teruel, -8}, {barcelona,30}, {teruel,10}].

% Proceso Master
% Para construir el sistema de nodos usaremos un proceso inicial, el máster, que inicializaremos con dos parámetros:
% Info: una lista de valores.
% N: Número de nodos a crear.
% Con esta información el máster:
% 1. Repartirá la lista Info en N trozos (de longitud similar).
% 2. Creará N nodos (procesos), cada uno recibiendo un trozo de Info. También recibirá el pid del máster y el número de nodo (entre 1 y N).
init(Info, N) ->
	SplitList = split(Info, N),
	io:format("Spliteamos: ~p~n",[SplitList]),
	start(SplitList, N).

start(SplitList, N) -> spawn(fun() -> create_nodes(SplitList, N, [], 0, self()) end).

create_nodes([], _, _, _, _) -> ok;
create_nodes([HeadList| TailList], N, NodePids, NodeNumber, MasterPid) ->
	if N > 0 ->
		Pid = spawn(fun() -> create_node(HeadList, MasterPid, NodeNumber + 1) end),
		create_nodes(TailList, N - 1, lists:append([NodePids, [Pid]]), NodeNumber + 1, MasterPid);
		true -> void
	end,
	loop(NodePids),
	self() ! { mapreduce, self(), 1, 1 }.

create_node(List, PidMaster, NodeNumber) ->
	node:loop(List, PidMaster, NodeNumber).

loop(NodePids) ->
	io:format("Ahora se pueden mandar las funciones Fmap y Freduce ~n"),
	receive
		{ mapreduce, Parent, Fmap, Freduce } -> 
			spawn(fun() -> dealer:init(Parent, Fmap, Freduce, NodePids) end),
			loop(NodePids)
	end.

% master_message(mapreduce, Parent, Fmap, Freduce).
% El máster guardará la lista de Pids de los nodos creados, y entrará en un bucle sin fin que se dedica a recibir mensajes mapreduce y procesarlos. Los mensajes mapreduce que espera el máster tienen la estructura {mapreduce, Parent, Fmap, Freduce} donde:
% Parent: pid del proceso que le está enviando el mensaje
% Fmap: Una función que realiza funciones de filtrado y ordenación. Recibe como entrada una lista (el fragmento de Info contenido en un nodo) y la posición del nodo (el valor entre 1 y N que lo distingue) y devuelve una lista de parejas {clave, valor}.
% Freduce: La función que procesa los resultados obtenidos de los nodos, ya combinados. Recibe una clave y dos valores, y produce una salida. Difiere de la versión habitual de reduce que se supone que recibe la lista completa de valores asociada a una clave; aquí los procesamos según llegan para aumentar el paralelismo aunque a costa de perder generalidad.

split([], _) -> [];
split(L, N) when length(L) < N -> [L];
split(L, N) ->
	{ A, B } = lists:split(N, L),
	[A | split(B, N)].

% Proceso Master
% Para construir el sistema de nodos usaremos un proceso inicial, el máster, que inicializaremos con dos parámetros:
% Info: una lista de valores.
% N: Número de nodos a crear.
% Con esta información el máster:
% 1. Repartirá la lista Info en N trozos (de longitud similar).
% 2. Creará N nodos (procesos), cada uno recibiendo un trozo de Info. También recibirá el pid del máster y el número de nodo (entre 1 y N).
% ================================================================
% El máster guardará la lista de Pids de los nodos creados, y entrará en un bucle sin fin que se dedica a recibir mensajes mapreduce y procesarlos. Los mensajes mapreduce que espera el máster tienen la estructura {mapreduce, Parent, Fmap, Freduce} donde:
% Parent: pid del proceso que le está enviando el mensaje
% Fmap: Una función que realiza funciones de filtrado y ordenación. Recibe como entrada una lista (el fragmento de Info contenido en un nodo) y la posición del nodo (el valor entre 1 y N que lo distingue) y devuelve una lista de parejas {clave, valor}.
% Freduce: La función que procesa los resultados obtenidos de los nodos, ya combinados. Recibe una clave y dos valores, y produce una salida. Difiere de la versión habitual de reduce que se supone que recibe la lista completa de valores asociada a una clave; aquí los procesamos según llegan para aumentar el paralelismo aunque a costa de perder generalidad.
% ==================================================================
% Cuando el máster recibe un mensaje mapreduce, crea un proceso que será el encargado de repartir las tareas map a los nodos, recibirlas, crear los procesos reduce y finalmente devolver el resultado. A continuación el proceso máster vuelve al bucle, donde esperará la llegada de un nuevo mensaje mapreduce. El proceso creado para tratar la petición mapreduce recibirá los pids de los nodos y la información del mensaje ({mapreduce, Parent, Fmap, Freduce}). A continuación este proceso:
% 1) Les pasa un mensaje {startmap, self(), Fmap} a los N nodos.
% 2) Crea un nuevo diccionario (dict, ver las referencias más abajo), que permitirá saber los pids de los nodos reduce asociados a cada clave, y entra en un modo de espera a recibir mensajes para reunir los resultados de Fmap. En este estado se reciben dos tipos de mensajes {Clave,Valor} → son mensajes enviados por un nodo que está procesando su trozo de información. Lo que hace es:
% 1. Si la clave ya está en el diccionario simplemente enviar el mensaje {newvalue, Valor} al proceso reduce asociado.
% 2. Si la clave no existe en el diccionario crear un nuevo proceso reduce al que se pasa inicialmente el valor {self(), Freduce, Clave, Valor}. 
% {end} → Un nodo ha terminado de procesar el Fmap.
% Este estado sigue hasta que todos los nodos han acabado (se han recibido N señales end).
% En ese momento se envía a todos los procesos reduce el mensaje end.
% 3) Bucle de recepción de mensajes análogo al de la fase 2, pero ahora recolectando los mensajes {Clave, Valor} que devuelven los procesos reduce y acumulando en una lista los resultados.
% Acabará cuando se hayan recibido R mensajes, con R el número de procesos reduce. Al final se obtiene un nuevo diccionario que es el que se envía al padre.