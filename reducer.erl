-module(reducer).

-export([init/4, loop/4]).

% Funcion para inicializar al reducer y encender el loop
init(IdParent, Freduce, Key, Value) ->
	loop(IdParent, Freduce, Key, Value).

% Funcion loop de los reducers donde se aplica Freduce o se mandan los resultados al dealer
loop(IdParent, Freduce, Key, Value) ->
	receive
		{ newValue, NewValue } ->
			Result = Freduce(Key, Value, NewValue),
			loop(IdParent, Freduce, Key, Result);
		'end' ->
			IdParent ! { reducer_results, { Key, Value } }
	end.
