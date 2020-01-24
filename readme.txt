Instrucciones para ejecutar el codigo:

1 - Cargar los siguientes datos:
L = [{madrid,34}, {barcelona,21}, {madrid,22}, {barcelona,19}, {teruel,-5}, {teruel, 14}, {madrid,37}, {teruel, -8}, {barcelona,30}, {teruel,10}].
L1 = [{el,1}, {yo,1}, {yo,1}, {tu,1}, {el,1}, {nos,1}, {quiero,1}, {tu, 1}, {el,1}, {yo,1}].

2 - Ejecutar los siguientes comandos:
c(master).
c(node).
c(dealer).
c(reducer).
c(tests).

3 - Ejecutar la siguiente linea:
P = master:init(L, 3).
P1 = master:init(L1, 3).

4 - Ejecutar la siguiente linea:
P ! {mapreduce, self(), fun tests:filter/2, fun tests:sum/3}.
P1 ! {mapreduce, self(), fun tests:nothing/2, fun tests:sum/3}.