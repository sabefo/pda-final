-module(tests).

-export([filter/3]).

% L = [{madrid,34}, {barcelona,21}, {madrid,22}, {barcelona,19}, {teruel,-5}, {teruel, 14}, {madrid,37}, {teruel, -8}, {barcelona,30}, {teruel,10}].
filter([], _, Z) -> lists:flatten(Z);
filter([{ X, Y }|T], N, Z) ->
	if
		Y > N ->
			filter(T, N, lists:append(Z, [{ X, Y }]));
		true ->
			filter(T, N, Z)
	end.
