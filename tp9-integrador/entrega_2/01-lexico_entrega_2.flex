package compilador;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.HashMap;
import java.util.Map;


// Para escribir el archivo de la tabla de simbolos
import compilador.TablaSimbolos.*;
import java_cup.runtime.*;

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
	/* 2¹⁶ */
	private final int INT_MAX_LEN = 65536;	
	
	// Tabla de símbolos
	private List<Map<Columna, String>> symtbl;
	
	
	// Inicializa la tabla de simbolos
	private void iniTable() {
		TablaSimbolos.escribirArchivo(null, null, false);
		this.symtbl = TablaSimbolos.leerArchivo(null);
		EscribeAnalisis.escribir("", false);
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
	
	
	// Verifica que el string no tenga mas de 30 caracteres
	public boolean checkStr(String s){
		if (s.isEmpty() || (s.length() > 30)){
			return false;
		}
		return true;
	}
	
	// Limpia strings
	public String valorString(String s) {
		if (s.length() >= 2 && s.charAt(0) == '"' && s.charAt(s.length() - 1) == '"'){
			s = s.substring(1, s.length() - 1);
		}
		return s;
	}
	
	
	// Imprime cada par token:lexema hallado
	public void anuncio(String token){
		System.out.println("***Nuevo hallazgo***");
		System.out.println("\tToken = " + token + "\n\tLexema = '" + yytext() + "'\n");
		EscribeAnalisis.escribir("***Nuevo hallazgo***", true);
		EscribeAnalisis.escribir("\tToken = " + token + "\n\tLexema = '" + yytext() + "'\n", true);
	}
	
%}


 // ============================================================================


FIN_LINEA = \r|\n|\r\n
ESPACIO = {FIN_LINEA}|\t|\f|[ ]

DIGITO = [0-9]
LETRA = [a-zA-Z]
PUNTO = "."
COMILLA = \"


CTE_INT = {DIGITO} | {DIGITO}+
CTE_FLOAT = {DIGITO}+{PUNTO} | {PUNTO}{DIGITO}+ | {DIGITO}+{PUNTO}{DIGITO}+
CTE_STR = {COMILLA}[^\"]*{COMILLA}

INT = [I][N][T]|[I][n][t]|[i][n][t]
FLOAT = [F][L][O][A][T]|[F][l][o][a][t]|[f][l][o][a][t]
STRING =  [S][T][R][I][N][G]|[S][t][r][i][n][g]|[s][t][r][i][n][g]

TIPO = {INT}|{FLOAT}|{STRING}

IF = [I][F]|[I][f]|[i][f]
ELSE = [E][L][S][E]|[E][l][s][e]|[e][l][s][e]
WHILE = [W][H][I][L][E]|[W][h][i][l][e]|[w][h][i][l][e]
PRINT = [P][R][I][N][T]|[P][r][i][n][t]|[p][r][i][n][t]
TAKE = [T][A][K][E]|[T][a][k][e]|[t][a][k][e]

ID = {LETRA}({LETRA}|{DIGITO}|\_)*

COMEN_ABRE = \<\/
COMEN_CIERRA = \/\>
COMENTARIO = {COMEN_ABRE}[^\/\>]*{COMEN_CIERRA}

%%

<YYINITIAL> {
    "BEGIN.PROGRAM"		{anuncio("BEGIN.PROGRAM");		}//return new Symbol(Simbolo.BEGIN_PROGRAM)}
    "END.PROGRAM"		{anuncio("END.PROGRAM"); 		}//return new Symbol(Simbolo.END_PROGRAM);}
    "DECLARE"           {anuncio("DECLARE");iniTable(); }//return new Symbol(Simbolo.DECLARE);}
    "ENDDECLARE"		{anuncio("ENDDECLARE"); 		}//return new Symbol(Simbolo.ENDDECLARE);}
    {TAKE}				{anuncio("TAKE"); 				}//return new Symbol(Simbolo.TAKE);}
    {PRINT}             {anuncio("PRINT"); 				}//return new Symbol(Simbolo.PRINT);}
    {IF}                {anuncio("IF"); 				}//return new Symbol(Simbolo.IF);}
    {ELSE}              {anuncio("ELSE"); 				}//return new Symbol(Simbolo.ELSE);}
    {WHILE}             {anuncio("WHILE"); 				}//return new Symbol(Simbolo.WHILE);}
    {TIPO}				{anuncio("TIPO"); 				}//return new Symbol(Simbolo.TIPO);}
	"="                	{anuncio("ASIGNA"); 			}//return new Symbol(Simbolo.ASIGNA);}
    "=="                {anuncio("IGUAL"); 				}//return new Symbol(Simbolo.IGUAL);}
    "<>"                {anuncio("DISTINTO"); 			}//return new Symbol(Simbolo.DISTINTO);} 
    "<"	                {anuncio("MENOR"); 				}//return new Symbol(Simbolo.MENOR);}
    "<="                {anuncio("MENOR_IGUAL"); 		}//return new Symbol(Simbolo.MENOR_IGUAL);}
    ">"                 {anuncio("MAYOR"); 				}//return new Symbol(Simbolo.MAYOR);}
    ">="                {anuncio("MAYOR_IGUAL"); 		}//return new Symbol(Simbolo.MAYOR_IGUAL);}
    "&&"				{anuncio("AND"); 				}//return new Symbol(Simbolo.AND);}
    "||"				{anuncio("OR"); 				}//return new Symbol(Simbolo.OR);}
    "+"                 {anuncio("SUMA");				}//return Symbol(Simbolo.SUMA);}
    "-"		            {anuncio("RESTA");				}//return Symbol(Simbolo.RESTA);}
    "/"                 {anuncio("DIVIDE");				}//return Symbol(Simbolo.DIVIDE);}
    "*"                 {anuncio("MULTIPLICA");			}//return Symbol(Simbolo.MULTIPLICA);}
    "("                 {anuncio("PAR_ABRE"); 			}//return new Symbol(Simbolo.PAR_ABRE);}
	")"                 {anuncio("PAR_CIERRA"); 		}//return new Symbol(Simbolo.PAR_CIERRA);}
    "{"                 {anuncio("LLAVE_ABRE"); 		}//return new Symbol(Simbolo.LLAVE_ABRE);}
    "}"                 {anuncio("LLAVE_CIERRA"); 		}//return new Symbol(Simbolo.LLAVE_CIERRA);}  
    "["                 {anuncio("COR_ABRE"); 			}//return new Symbol(Simbolo.COR_ABRE);}  
    "]"                 {anuncio("COR_CIERRA"); 		}//return new Symbol(Simbolo.COR_CIERRA);}  
    ";"                 {anuncio("PUNTO_COMA"); 		}//return new Symbol(Simbolo.PUNTO_COMA);}
    ","                 {anuncio("COMA"); 				}//return new Symbol(Simbolo.COMA);}
    
	{ID}				{anuncio("ID"); addSym(yytext(), "ID", null);} //return new Symbol(Simbolo.ID);}
	
	{CTE_INT}			{
							anuncio("CTE_INT");					
							if (!checkInt(yytext())){
								System.out.println("Lexema " + yytext() + " excede el valor maximo de un Integer (" + INT_MAX_LEN + ").\n");	
								EscribeAnalisis.escribir("Lexema " + yytext() + " excede el valor maximo de un Integer (" + INT_MAX_LEN + ").\n", true);
							}
							else{
								addSym("_" + yytext(), "CTE_INT", yytext(), null);
								//return new Symbol(Simbolo.CTE_INT);
							}
						}
					
	{CTE_FLOAT}			{anuncio("CTE_FLOAT");addSym("_" + yytext(), "CTE_FLOAT", yytext(), null); }//return new Symbol(Simbolo.CTE_FLOAT);}
						
	{CTE_STR}			{
							anuncio("CTE_STR");
							if (!checkStr(yytext())){
								System.out.println("Lexema " + yytext() + " excede la longitud maxima de un String (" + STR_MAX_LEN + ").\n");		
							}
							else{
								addSym("_" + yytext(), "CTE_STR",  valorString(yytext()), valorString(yytext()).length());
								//return new Symbol(Simbolo.CTE_STR);
							}
						}
	
	{COMENTARIO}		{/* no hacer nada */}
	{ESPACIO}			{/* no hacer nada*/ }
	{FIN_LINEA}			{/* no hacer nada*/ }
}


[^]	{ 
	EscribeAnalisis.escribir("Caracter no permitido: <" + yytext() + "> en la linea " + yyline + " columna " + yycolumn + ".", true);
	throw new Error("Caracter no permitido: <" + yytext() + "> en la linea " + yyline + " columna " + yycolumn + "."); 
}

















