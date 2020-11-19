## Modo de uso:
``java -jar compilador.jar <archivo_prueba.txt>``

En el repo se dejaron 3 versiones de prueba diferentes:
- *prueba_1.txt*: contiene declaraciones y la sentencia de invocacion a la funcion print.
- *prueba_2.txt*: contiene solo la sentencia de invocación a la funcion print.
- *prueba_3-completa.txt*: contiene declaraciones y sentencias.

## Salida:
*compilador.jar* mostrará en pantalla las reglas que se aplicaron para parsear el codigo fuente procesado. Adicionalmente, se escriben tres archivos en formato *.txt*:
- *tabla_simbolos.txt*: contiene la tabla de simbolos.
- *analisis_lexico.txt*: en caso de que se quieran ver los tokens y lexemas reconocidos.
- *analisis_gramatico.txt*: una copia del output mostrado por el *.jar*.
