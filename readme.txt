Instrucciones para ejecutar el codigo:

1 - Cargar los siguientes datos:
L = [{madrid, 34}, {barcelona, 21}, {madrid, 22}, {barcelona, 19}, {teruel, -5}, {teruel, 14}, {madrid, 37}, {teruel, -8}, {barcelona, 30}, {teruel, 10}].
L1 = [{volvo, 1}, {bMW, 1}, {ford, 1}, {mazda, 1}, {since, 1}, {has, 1}, {allen, 1}, {ever, 1}, {mated, 1}, {life, 1}, {surely, 1}, {we, 1}, {could, 1}, {achieve, 1}, {universal, 1}, {harmony, 1}, {simply, 1}, {by, 1}, {banning, 1}, {yodelling, 1}, {sex, 1}, {is, 1}, {better, 1}, {than, 1}, {talk, 1}, {ask, 1}, {anybody, 1}, {in, 1}, {this, 1}, {bar, 1}, {talk, 1}, {is, 1}, {what, 1}, {you, 1}, {suffer, 1}, {through, 1}, {so, 1}, {you, 1}, {can, 1}, {get, 1}, {to, 1}, {sex, 1}, {money, 1}, {is, 1}, {better, 1}, {than, 1}, {poverty, 1}, {only, 1}, {for, 1}, {financial, 1}, {reasons, 1}, {i, 1}, {took, 1}, {one, 1}, {course, 1}, {in, 1}, {existential, 1}, {philosophy, 1}, {at, 1}, {york, 1}, {university, 1}, {on, 1}, {the, 1}, {final, 1}, {they, 1}, {gave, 1}, {me, 1}, {ten, 1}, {questions, 1}, {i, 1}, {couldnt, 1}, {answer, 1}, {a, 1}, {single, 1}, {one, 1}, {em, 1}, {you, 1}, {know, 1}, {i, 1}, {left, 1}, {em, 1}, {all, 1}, {blank, 1}, {i, 1}, {got, 1}, {a, 1}, {hundred, 1}, {too, 1}, {much, 1}, {sex, 1}, {could, 1}, {lead, 1}, {to, 1}, {you, 1}, {doing, 1}, {yourself, 1}, {an, 1}, {injury, 1}, {though, 1}, {turning, 1}, {into, 1}, {brandon, 1}, {sullivan, 1}, {sex, 1}, {sex, 1}, {sex, 1}, {sex, 1}, {sex, 1}, {sex, 1}, {sex, 1}, {sex, 1}, {sex, 1}, {sex, 1}, {sex, 1}].
L2 = [{harry_potter, english}, {quijote, spanish}, {game_trhones, english}, {miserables, french}, {enders_game, english}, {pedro_paramo, spanish}, {lean_startup, english}, {bible, latin}, {leviatan, english}, {tregua, spanish}].

2 - Ejecutar los siguientes comandos:
c(master).
c(node).
c(dealer).
c(reducer).
c(functions).

El archivo functions contempla las funciones Fmap y Freduce

3 - Ejecutar la siguiente linea:
P = master:init(L, 3).
P1 = master:init(L1, 7).
P2 = master:init(L2, 3).

4 - Ejecutar la siguiente linea:
P ! {mapreduce, self(), fun functions:filter/2, fun functions:max/3}.
P1 ! {mapreduce, self(), fun functions:nothing/2, fun functions:sum/3}.
P2 ! {mapreduce, self(), fun functions:english_books/2, fun functions:sum/3}.