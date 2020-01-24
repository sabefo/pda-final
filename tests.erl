-module(tests).

-export([filter/3, filter/2, sum/3, nothing/2]).

% L = [{madrid,34}, {barcelona,21}, {madrid,22}, {barcelona,19}, {teruel,-5}, {teruel, 14}, {madrid,37}, {teruel, -8}, {barcelona,30}, {teruel,10}].
% L1 = [{el,1}, {yo,1}, {yo,1}, {tu,1}, {el,1}, {nos,1}, {quiero,1}, {tu, 1}, {el,1}, {yo,1}].
filter([], _, Z) -> lists:flatten(Z);
filter([{ X, Y }|T], N, Z) ->
	if
		Y > 10 ->
			filter(T, N, lists:append(Z, [{ X, Y }]));
		true ->
			filter(T, N, Z)
	end.

filter(X, Y) -> filter(X, Y, []).

nothing(Info, _) -> Info.

sum(_, Value, NewValue) ->
	Value + NewValue.
