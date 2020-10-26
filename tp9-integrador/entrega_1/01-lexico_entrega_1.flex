package compilador;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

import java_cup.runtime.*;
//import java_cup.sym; 

// Para escribir el archivo de la tabla de simbolos
import compilador.TablaSimbolos.*;


%%

%cupsym Simbolo
%cup
%public
%class Lexico
%line
%column
%char


 // ============================================================================

%{

	// Valores maximos
	private final int STR_MAX_LEN = 30;
	/* 2¹⁶*/
	private final int INT_MAX_LEN = 65536;	
	private final float FLOAT_MAX_LEN = 0;
	
	// Tabla de símbolos
	private List<Map<Columna, String>> symtbl;
	
	
	// Inicializa la tabla de simbolos
	private void iniTable() {
		TablaSimbolos.escribirArchivo(null, null, false);
		this.symtbl = TablaSimbolos.leerArchivo(null);
	}
	
	
	// Agrega un simbolo de ID de variable
	public void addSym(String nombre, String token, String tipo) {
		boolean encontrado = false;
		int i = 0;
		while (!encontrado && i < symtbl.size()) {
			encontrado = symtbl.get(i).get(Columna.NOMBRE).equals(nombre);
			i++;
		}
		if (!encontrado) {
			Map<Columna, String> sym = new HashMap<Columna, String>();
			sym.put(Columna.NOMBRE, nombre);
			sym.put(Columna.TOKEN, token);
			sym.put(Columna.TIPO, tipo);
			this.symtbl.add(sym);
			TablaSimbolos.escribirArchivo(Arrays.asList(sym), null, true);
		}
	}
	
	
	// Agrega una constante 
	public void addSym(String nombre, String token, String valor, Integer len) {
		boolean encontrado = false;
		int i = 0;
		while (!encontrado && i < symtbl.size()) {
			encontrado = symtbl.get(i).get(Columna.NOMBRE).equals(nombre);
			i++;
		}
		if (!encontrado) {
			Map<Columna,String> sym = new HashMap<Columna, String>();
			sym.put(Columna.NOMBRE, nombre);
			sym.put(Columna.TOKEN, token);
			sym.put(Columna.VALOR, valor);
			if (len != null) sym.put(Columna.LEN, String.valueOf(len));
			this.symtbl.add(sym);
			TablaSimbolos.escribirArchivo(Arrays.asList(sym), null, true);
		}
	}
	
	
	// Verifica la cantidad de bits del integer (0-65535) (recibido como string)
	public boolean checkInt(String s){
		// Verifico que s no este vacia o tenga más de 5 digitos
		if (s.isEmpty() || s.length() > 5){
			return false;
		}
		try{
			// Parseo a integer
			Integer number = Integer.valueOf(s);
			// Verifico que no exceda el maximo valor
			if (number > INT_MAX_LEN){
				return false;
			}
		}catch(Exception e){
			System.out.println("Error parseando lexema " + yytext() + ".");
			System.out.println(e.toString());
			return false;
		}	
		return true;
	}
	

	// Verifica la cantidad de bits del float (recibido como string)
	public boolean checkFloat(String s){
		// Verifico que s no este vacia
		if (s.isEmpty()){
			return false;
		}
		try{
			// Parseo a float
			Float number = Float.valueOf(s);
			// Verifico que no exceda el maximo valor
			if (number > FLOAT_MAX_LEN){
				return false;
			}
		}catch(Exception e){
			System.out.println("Error parseando lexema " + yytext() + ".");
			System.out.println(e.toString());
			return false;
		}
		return true;
	}
	
	
	// Verifica que el string no tenga mas de 30 caracteres
	public boolean checkStr(String s){
		if (s.isEmpty() || (s.length() > 30)){
			return false;
		}
		return true;
	}
	
	
	// Imprime cada par token:lexema hallado
	public void anuncio(String token){
		System.out.println("***Nuevo hallazgo***");
		System.out.println("\tToken = " + token + ".\n\tLexema = " + yytext() + ".\n");
	}
	
%}


 // ============================================================================


FIN_LINEA = \r|\n|\r\n
ESPACIO = {FIN_LINEA}|\t|\f

DIGITO = [0-9]
LETRA = [a-zA-Z]
PUNTO = "."

CHAR = {DIGITO}|{LETRA}|{ESPACIO}

COMILLA = \"

CONST_INT = 0 | [1-9]{DIGITO}+
CONST_FLOAT = {DIGITO}*{PUNTO}{DIGITO}+ | {DIGITO}+{PUNTO}{DIGITO}*

CONST_FLOAT = ({DIGITO}+{PUNTO}{DIGITO}+){1,30} | {PUNTO}{DIGITO}{1,30} | {DIGITO}{1,32}{PUNTO}

CONST_STR = {COMILLA}{CHAR}*{COMILLA}

ID = {LETRA}({LETRA}|{DIGITO}|\_)*

COMENTARIO = "</"[^"</"]*"/>"

%%

<YYINITIAL> {
    "BEGIN.PROGRAM"		{anuncio("BEGIN.PROGRAM");return new Symbol(Simbolo.BEGIN_PROGRAM, yycolumn, yyline);}
    "END.PROGRAM"		{anuncio("END.PROGRAM");return new Symbol(Simbolo.END_PROGRAM, yycolumn, yyline);}
    "DECLARE"           {anuncio("DECLARE");iniTable(); return new Symbol(Simbolo.DECLARE, yycolumn, yyline);}
    "ENDDECLARE"		{anuncio("ENDDECLARE");return new Symbol(Simbolo.ENDDECLARE, yycolumn, yyline);}
    "TAKE"				{anuncio("TAKE");return new Symbol(Simbolo.TAKE, yycolumn, yyline);}
    "PRINT"             {anuncio("PRINT");return new Symbol(Simbolo.PRINT, yycolumn, yyline);}
    "IF"                {anuncio("IF");return new Symbol(Simbolo.IF, yycolumn, yyline);}
    "ELSE"              {anuncio("ELSE");return new Symbol(Simbolo.ELSE, yycolumn, yyline);}
    "WHILE"             {anuncio("WHILE");return new Symbol(Simbolo.WHILE, yycolumn, yyline);}
	":="                {anuncio(":=");return new Symbol(Simbolo.ASIGNA, yycolumn, yyline);}
    "=="                {anuncio("==");return new Symbol(Simbolo.IGUAL, yycolumn, yyline, new String(yytext()));}
    "<>"                {anuncio("<>");return new Symbol(Simbolo.DISTINTO, yycolumn, yyline, new String(yytext()));} 
    "<"                 {anuncio("<");return new Symbol(Simbolo.MENOR, yycolumn, yyline, new String(yytext()));}
    "<="                {anuncio("<=");return new Symbol(Simbolo.MENOR_IGUAL, yycolumn, yyline, new String(yytext()));}
    ">"                 {anuncio(">");return new Symbol(Simbolo.MAYOR, yycolumn, yyline, new String(yytext()));}
    ">="                {anuncio(">=");return new Symbol(Simbolo.MAYOR_IGUAL, yycolumn, yyline, new String(yytext()));}
    "+"                 {anuncio("+");return new Symbol(Simbolo.SUMA, yycolumn, yyline, new String(yytext()));}
    "-"                 {anuncio("-");return new Symbol(Simbolo.RESTA, yycolumn, yyline, new String(yytext()));}
    "/"                 {anuncio("/");return new Symbol(Simbolo.DIVIDE, yycolumn, yyline, new String(yytext()));}
    "*"                 {anuncio("*");return new Symbol(Simbolo.MULTIPLICA, yycolumn, yyline, new String(yytext()));}
    "("                 {anuncio("(");return new Symbol(Simbolo.PAR_ABRE, yycolumn, yyline);}
	")"                 {anuncio(")");return new Symbol(Simbolo.PAR_CIERRA, yycolumn, yyline);}
    "{"                 {anuncio("{");return new Symbol(Simbolo.LLAVE_ABRE, yycolumn, yyline);}
    "}"                 {anuncio("}");return new Symbol(Simbolo.LLAVE_CIERRA, yycolumn, yyline);}  
    "["                 {anuncio("[");return new Symbol(Simbolo.COR_ABRE, yycolumn, yyline);}  
    "]"                 {anuncio("]");return new Symbol(Simbolo.COR_CIERRA, yycolumn, yyline);}  
    ";"                 {anuncio(";");return new Symbol(Simbolo.PUNTO_COMA, yycolumn, yyline);}
    ","                 {anuncio(",");return new Symbol(Simbolo.COMA, yycolumn, yyline);}

	{ID}				{anuncio("ID"); addSym(yytext(), "ID", null);}
	
	{CONST_INT}			{
							if (!checkInt(yytext())){
								System.out.println("Lexema " + yytext() + " excede el valor máximo de un Integer (" + INT_MAX_LEN + ").");	
							}
							else{
								anuncio("CONST_INT");
							}
							anuncio("CONST_INT");
							addSym("_" + yytext(), "CONST_INT", yytext(), null);
                            return new Symbol(Simbolo.CONST_INT, yycolumn, yyline, new String(yytext()));
						}
					
	{CONST_FLOAT}		{
							if (!checkFloat(yytext())){
								System.out.println("Lexema " + yytext() + " excede el valor máximo de un Float (" + FLOAT_MAX_LEN + ").");	
							}
							else{
								anuncio("CONST_FLOAT");
							}
							anuncio("CONST_FLOAT");
							addSym("_" + yytext(), "CONST_FLOAT", yytext(), null);
                            return new Symbol(Simbolo.CONST_FLOAT, yycolumn, yyline, new String(yytext()));
						}
						
	{CONST_STR}			{
							if (!checkStr(yytext())){
								System.out.println("Lexema " + yytext() + " excede la longitud maxima de un String (" + STR_MAX_LEN + ").");		
							}
							else{
								anuncio("CONST_STR");
							}
							anuncio("CONST_STR");
							addSym("_" + yytext(), "CONST_STR", yytext(), null);
                            return new Symbol(Simbolo.CONST_STR, yycolumn, yyline, new String(yytext()));
						}
	
	{COMENTARIO}		{/* se ignora el contenido */}
	{ESPACIO}			{/* no hacer nada */}
}


[^]	{ 
	throw new Error("Caracter no permitido: <" + yytext() + "> en la linea " + yyline + " columna " + yycolumn + "."); 
}
























