------------------------------------------------
% SISTEMA DE RECOMENDACIÓN DE PRODUCTOS EN PROLOG
% ------------------------------------------------

% ----------------------------
% BASE DE HECHOS
% ----------------------------

% Usuarios registrados y sus intereses
usuario(juan, [tecnologia, ropa]).
usuario(maria, [tecnologia, accesorios]).
usuario(carlos, [ropa, tecnologia]).
usuario(ana, [tecnologia, accesorios]).
usuario(luis, [accesorios, tecnologia]).

% Definición de productos con su categoría y precio
producto(laptop, tecnologia, 1200).
producto(smartphone, tecnologia, 800).
producto(camiseta, ropa, 20).
producto(zapatos, ropa, 50).
producto(auriculares, tecnologia, 100).
producto(mochila, accesorios, 40).
producto(tablet, tecnologia, 600).
producto(reloj, accesorios, 150).
producto(chaqueta, ropa, 80).
producto(tv, tecnologia, 900).

% Historial de compras (Usuario, Producto, Fecha de Compra)
compra(juan, laptop, '2024-01-10').
compra(maria, smartphone, '2024-02-15').
compra(maria, camiseta, '2024-03-05').
compra(carlos, zapatos, '2024-04-20').
compra(juan, auriculares, '2024-05-12').
compra(maria, mochila, '2024-06-30').
compra(carlos, laptop, '2024-07-25').
compra(ana, tablet, '2024-08-01').
compra(luis, reloj, '2024-09-10').
compra(juan, chaqueta, '2024-10-05').
compra(luis, tv, '2024-11-15').

% Calificaciones otorgadas por los usuarios (Usuario, Producto, Calificación)
calificacion(juan, laptop, 5).
calificacion(maria, smartphone, 4).
calificacion(maria, camiseta, 2).
calificacion(carlos, zapatos, 5).
calificacion(juan, auriculares, 3).
calificacion(maria, mochila, 4).
calificacion(carlos, laptop, 5).
calificacion(ana, tablet, 3).
calificacion(luis, reloj, 4).
calificacion(juan, chaqueta, 5).
calificacion(luis, tv, 5).

% ----------------------------
% CONSULTAS Y REGLAS
% ----------------------------

% Determinar si un usuario ha comprado un producto
comprado_por_usuario(Usuario, Producto) :-
    compra(Usuario, Producto, _).

% Recomendación basada en compras similares entre usuarios
recomendar_producto_compra_similar(Usuario, Producto) :-
    compra(Usuario, Producto1, _),
    compra(OtroUsuario, Producto1, _),
    Usuario \= OtroUsuario,
    compra(OtroUsuario, Producto, _),
    \+ compra(Usuario, Producto, _).

% Recomendación basada en intereses del usuario
recomendar_producto_por_interes(Usuario, Producto) :-
    usuario(Usuario, Intereses),
    member(Categoria, Intereses),
    producto(Producto, Categoria, _),
    \+ compra(Usuario, Producto, _).

% Recomendación basada en calificaciones altas
recomendar_producto_por_calificacion(Usuario, Producto) :-
    calificacion(OtroUsuario, Producto, Calificacion),
    Calificacion >= 4,
    Usuario \= OtroUsuario,
    \+ compra(Usuario, Producto, _).

% Recomendación basada en productos similares (misma categoría)
recomendar_producto_similar(Usuario, Producto) :-
    compra(Usuario, ProductoComprado, _),
    producto(ProductoComprado, Categoria, _),
    producto(Producto, Categoria, _),
    ProductoComprado \= Producto,
    \+ compra(Usuario, Producto, _).

% Cualquier tipo de recomendación (unifica todas las estrategias)
recomendar_producto(Usuario, Producto) :-
    recomendar_producto_compra_similar(Usuario, Producto);
    recomendar_producto_por_interes(Usuario, Producto);
    recomendar_producto_por_calificacion(Usuario, Producto);
    recomendar_producto_similar(Usuario, Producto).

% Generación de una lista de productos recomendados
recomendar_lista(Usuario, Lista) :-
    findall(Producto, recomendar_producto(Usuario, Producto), ProductosDuplicados),
    sort(ProductosDuplicados, Lista).

% Implementación de first_n para obtener los primeros N elementos de una lista
first_n(0, _, []) :- !.
first_n(_, [], []) :- !.
first_n(N, [X|Xs], [X|Ys]) :-
    N > 0,
    N1 is N - 1,
    first_n(N1, Xs, Ys).

% Recomendación recursiva basada en usuarios indirectamente conectados
recomendar_recursivo(Usuario, Producto, UsuariosVisitados) :-
    compra(Usuario, Producto1, _),
    compra(OtroUsuario, Producto1, _),
    Usuario \= OtroUsuario,
    \+ member(OtroUsuario, UsuariosVisitados),
    recomendar_recursivo(OtroUsuario, Producto, [OtroUsuario|UsuariosVisitados]).
recomendar_recursivo(Usuario, Producto, _) :-
    recomendar_producto(Usuario, Producto).

% Punto de entrada para recomendar_recursivo
recomendar_recursivo(Usuario, Producto) :-
    recomendar_recursivo(Usuario, Producto, [Usuario]).

% Identificación de los productos mejor calificados (top 10)
obtener_top10_favoritos(ListaTop10) :-
    findall((Producto, Rating), (calificacion(_, Producto, Rating), Rating > 3), ListaOrdenada),
    sort(2, @>=, ListaOrdenada, Lista),
    first_n(10, Lista, ListaTop10).

% Implementación del predicado productos_mejor_calificados
productos_mejor_calificados(Usuario, Lista) :-
    findall((Producto, Rating), (calificacion(Usuario, Producto, Rating), Rating > 3), ListaOrdenada),
    sort(2, @>=, ListaOrdenada, Lista).

% Filtrado de recomendaciones según categoría
recomendar_por_categoria(Usuario, Categoria, Lista) :-
    findall(Producto, (recomendar_producto(Usuario, Producto), producto(Producto, Categoria, _)), ProductosDuplicados),
    sort(ProductosDuplicados, Lista).

% Obtención de usuarios con intereses de compra similares
usuarios_similares(Usuario, OtroUsuario) :-
    compra(Usuario, Producto, _),
    compra(OtroUsuario, Producto, _),
    Usuario \= OtroUsuario.

% Productos más adquiridos en el sistema
productos_populares(ListaConCantidad) :-
    findall(Producto, compra(_, Producto, _), TodosProductos),
    msort(TodosProductos, ProductosOrdenados),
    count_occurrences(ProductosOrdenados, ListaSinOrdenar),
    sort(2, @>=, ListaSinOrdenar, ListaConCantidad).

% Contar ocurrencias para productos populares
count_occurrences([], []).
count_occurrences([X|Xs], [(X, N)|Ys]) :-
    count_item(X, [X|Xs], Rest, 1, N),
    count_occurrences(Rest, Ys).

count_item(_, [], [], N, N).
count_item(X, [X|Xs], Rest, Acc, N) :-
    Acc1 is Acc + 1,
    count_item(X, Xs, Rest, Acc1, N).
count_item(X, [Y|Ys], [Y|Rest], Acc, N) :-
    X \= Y,
    count_item(X, Ys, Rest, Acc, N).

% Usuarios más activos en el sistema (mayor número de compras)
usuarios_activos(ListaConCantidad) :-
    findall(Usuario, compra(Usuario, _, _), TodosUsuarios),
    msort(TodosUsuarios, UsuariosOrdenados),
    count_occurrences(UsuariosOrdenados, ListaSinOrdenar),
    sort(2, @>=, ListaSinOrdenar, ListaConCantidad).

% ----------------------------
% CONSULTAS
% ----------------------------

% ¿Qué productos ha comprado Juan?
% ?- comprado_por_usuario(juan, Producto).

% ¿Qué producto se recomienda a Juan?
% ?- recomendar_producto(juan, Producto).

% ¿Qué lista de productos se recomienda a Juan?
% ?- recomendar_lista(juan, Lista).

% ¿Cuáles son los 10 productos mejor valorados?
% ?- obtener_top10_favoritos(Lista).

% ¿Qué productos mejor calificados ha comprado Juan?
% ?- productos_mejor_calificados(juan, Lista).

% ¿Qué productos de la categoría "tecnología" se recomiendan a Juan?
% ?- recomendar_por_categoria(juan, tecnologia, Lista).

% ¿Cuáles son los productos más comprados en el sistema?
% ?- productos_populares(Lista).

% ¿Quiénes son los usuarios más activos en compras?
% ?- usuarios_activos(Lista).

% Ver tipos específicos de recomendaciones para Juan
% ?- recomendar_producto_similar(juan, Producto).
