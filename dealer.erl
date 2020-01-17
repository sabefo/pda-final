-module(dealer).

-export([init/4, send_function/2, loop/0]).

% mapreduce, Parent, Fmap, Freduce
init(Parent, Fmap, Freduce, NodePids) ->
	send_function(NodePids, Fmap).

send_function([], _) -> loop();
send_function(NodePids, Fmap) ->
	hd(NodePids) ! { startmap, self(), Fmap },
	send_function(tl(NodePids), Fmap).

loop(Dictionary) ->
	receive
		{ ends, IdNode } ->
			io:format("Recibi ENDS ~n"),
			loop(Dictionary);
		{ { Key, Value }, IdNode } -> 
			io:format("Recibi K ~n~p",[Key]),
			io:format("Recibi V ~n~p",[Value]),
			loop()
	end.

	% if N > 0 ->
	% 	Pid = spawn(fun() -> create_node(hd(SplitList), MasterPid, NodeNumber + 1) end),
	% 	true -> void
	% end,
	% loop(NodePids).