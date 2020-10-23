import java_cup.runtime.Symbol;


%%


/*%cupsym Simbolo*/
%cup
%public
%class Lexico
%line
%column
%char


LETRA = [a-zA-Z]
DIGITO = [0-9]
ESPACIO = \t|\f
ID = {LETRA}({LETRA}|{DIGITO}|_)*
CONST_INT = {DIGITO}+
CONST_STRING = {COM}({LETRA}|{DIGITO}|{ESPACIO})*{COM}


%%

<YYINITIAL> {

{ID}		{System.out.println("Token ID encontrado, Lexema "+ yytext());}

{CONST_INT}		{System.out.println("Token CONST_INT, encontrado Lexema "+ yytext());}

":="		{System.out.println("Token ASIGN encontrado, Lexema "+ yytext());}

}

[^]		{ throw new Error("Caracter no permitido: <" + yytext() + "> en la linea " + yyline); }