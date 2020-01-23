% ES EL QUE ACUMULA LOS VALORES
% UNO POR CLAVE
-module(reducer).

-export([init/4, loop/4]).

init(IdParent, Freduce, Key, Value) ->
	loop(IdParent, Freduce, Key, Value).

loop(IdParent, Freduce, Key, Value) ->
	receive
		{ newValue, NewValue } ->
			io:format("Este es un reducer ~n"),
			% Result = Freduce(Key, Value, NewValue),
			Result = NewValue,
			loop(IdParent, Freduce, Key, Result);
		'end' -> IdParent ! { reducer, { Key, Value } }
	end.

% {IdParent, Freduce, Clave, Valor}
% Cuando se crean reciben como valores iniciales {IdParent, Freduce, Clave, Valor}. Cada proceso reduce actúa de la siguiente forma:
% 1) Al crearse apunta los valores de entrada. En particular apunta que el ValorActual que se tiene de momento es Valor.
% 2) Entra en un bucle a la espera de mensajes, que pueden ser de dos formas:
% {newvalue,ValorNuevo} → Aplica la función Freduce a (Clave,ValorActual,ValorNuevo).
% El valor que se obtiene será el nuevo ValorActual, y se continúa en el bucle.
% {end} → En este caso se envía al IdParent el mensaje {Clave,ValorActual} y el proceso se termina.
