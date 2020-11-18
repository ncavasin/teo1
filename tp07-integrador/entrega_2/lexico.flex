package compilador;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.HashMap;
import java.util.Map;


// Para escribir el archivo de la tabla de simbolos
import compilador.TablaSimbolos.*;
import java_cup.runtime.Symbol;

%%

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
	
	
	// Para escribir analisis lexico
	private EscribeAnalisis e = new EscribeAnalisis("analisis_lexico.txt");
	
	
	// Inicializa la tabla de simbolos
	private void iniTable() {
		TablaSimbolos.escribirArchivo(null, null, false);
		this.symtbl = TablaSimbolos.leerArchivo(null);
		e.escribir("", false);
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
	public String limpiarString(String s) {
		if (s.length() >= 2 && s.charAt(0) == '"' && s.charAt(s.length() - 1) == '"'){
			s = s.substring(1, s.length() - 1);
		}
		return s;
	}
	
	
	// Imprime cada par token:lexema hallado
	public void anuncio(String token){
		e.escribir("Lexema = '" + yytext() + "'\t\tToken = " + token + "\n", true);
	}
  
%}


 // ============================================================================


FIN_LINEA = \r|\n|\r\n
ESPACIO = {FIN_LINEA}|\t|\f|[ ]

DIGITO = [0-9]
LETRA = [a-zA-Z_]
PUNTO = "."
COMILLA = \"


CTE_INT = {DIGITO} | {DIGITO}+
CTE_FLOAT = {DIGITO}+{PUNTO} | {PUNTO}{DIGITO}+ | {DIGITO}+{PUNTO}{DIGITO}+
CTE_STR = {COMILLA}[^\"]*{COMILLA}

INT = [I][N][T]|[I][n][t]|[i][n][t]
FLOAT = [F][L][O][A][T]|[F][l][o][a][t]|[f][l][o][a][t]
STRING =  [S][T][R][I][N][G]|[S][t][r][i][n][g]|[s][t][r][i][n][g]


IF = [I][F]|[I][f]|[i][f]
ELSE = [E][L][S][E]|[E][l][s][e]|[e][l][s][e]
WHILE = [W][H][I][L][E]|[W][h][i][l][e]|[w][h][i][l][e]
PRINT = [P][R][I][N][T]|[P][r][i][n][t]|[p][r][i][n][t]
TAKE = [T][A][K][E]|[T][a][k][e]|[t][a][k][e]

ID = {LETRA}({LETRA}|{DIGITO}|\_)*

COMEN_ABRE = \<\/
COMEN_CIERRA = \/\>
COMENTARIO = {COMEN_ABRE}[^\/\>]*{COMEN_CIERRA}
 //COMENTARIO = {COMEN_ABRE}~{COMEN_CIERRA}

%%

<YYINITIAL> {
    "BEGIN.PROGRAM"		{anuncio("BEGIN.PROGRAM");		return new Symbol(sym.BEGIN_PROGRAM, yycolumn, yyline);}
    "END.PROGRAM"		{anuncio("END.PROGRAM"); 		return new Symbol(sym.END_PROGRAM, yycolumn, yyline);}
    "DECLARE"           {anuncio("DECLARE");iniTable(); return new Symbol(sym.DECLARE, yycolumn, yyline);}
    "ENDDECLARE"		{anuncio("ENDDECLARE"); 		return new Symbol(sym.ENDDECLARE, yycolumn, yyline);}
	"="                	{anuncio("ASIGNA"); 			return new Symbol(sym.ASIGNA, yycolumn, yyline);}
    "=="                {anuncio("IGUAL"); 				return new Symbol(sym.IGUAL, yycolumn, yyline, new String(yytext()));}
    "<>"                {anuncio("DISTINTO"); 			return new Symbol(sym.DISTINTO, yycolumn, yyline, new String(yytext()));}
    "<"	                {anuncio("MENOR"); 				return new Symbol(sym.MENOR, yycolumn, yyline, new String(yytext()));}
    "<="                {anuncio("MENOR_IGUAL"); 		return new Symbol(sym.MENOR_IGUAL, yycolumn, yyline, new String(yytext()));}
    ">"                 {anuncio("MAYOR"); 				return new Symbol(sym.MAYOR, yycolumn, yyline, new String(yytext()));}
    ">="                {anuncio("MAYOR_IGUAL"); 		return new Symbol(sym.MAYOR_IGUAL, yycolumn, yyline, new String(yytext()));}
    "&&"				{anuncio("AND"); 				return new Symbol(sym.AND, yycolumn, yyline, new String(yytext()));}
    "||"				{anuncio("OR"); 				return new Symbol(sym.OR, yycolumn, yyline, new String(yytext()));}
    "+"                 {anuncio("SUMA");				return new Symbol(sym.SUMA, yycolumn, yyline, new String(yytext()));}
    "-"		            {anuncio("RESTA");				return new Symbol(sym.RESTA, yycolumn, yyline, new String(yytext()));}
    "/"                 {anuncio("DIVIDE");				return new Symbol(sym.DIVIDE, yycolumn, yyline, new String(yytext()));}
    "*"                 {anuncio("MULTIPLICA");			return new Symbol(sym.MULTIPLICA, yycolumn, yyline, new String(yytext()));}
    "("                 {anuncio("PAR_ABRE"); 			return new Symbol(sym.PAR_ABRE, yycolumn, yyline);}
	")"                 {anuncio("PAR_CIERRA"); 		return new Symbol(sym.PAR_CIERRA, yycolumn, yyline);}
    "{"                 {anuncio("LLAVE_ABRE"); 		return new Symbol(sym.LLAVE_ABRE, yycolumn, yyline);}
    "}"                 {anuncio("LLAVE_CIERRA"); 		return new Symbol(sym.LLAVE_CIERRA, yycolumn, yyline);}
    "["                 {anuncio("COR_ABRE"); 			return new Symbol(sym.COR_ABRE, yycolumn, yyline);}
    "]"                 {anuncio("COR_CIERRA"); 		return new Symbol(sym.COR_CIERRA, yycolumn, yyline);}
    ","                 {anuncio("COMA"); 				return new Symbol(sym.COMA, yycolumn, yyline);}
    ";"                 {anuncio("PUNTO_COMA"); 		return new Symbol(sym.PUNTO_COMA, yycolumn, yyline);}
    
    {INT}				{anuncio("INT"); 				return new Symbol(sym.INT, yycolumn, yyline, new String(yytext()));}
    {FLOAT}				{anuncio("FLOAT"); 				return new Symbol(sym.FLOAT, yycolumn, yyline, new String(yytext()));}
	{STRING}			{anuncio("STRING");				return new Symbol(sym.STRING, yycolumn, yyline, new String(yytext()));}
    {TAKE}				{anuncio("TAKE"); 				return new Symbol(sym.TAKE, yycolumn, yyline);}
    {PRINT}             {anuncio("PRINT"); 				return new Symbol(sym.PRINT, yycolumn, yyline);}
    {IF}                {anuncio("IF"); 				return new Symbol(sym.IF, yycolumn, yyline);}
    {ELSE}              {anuncio("ELSE"); 				return new Symbol(sym.ELSE, yycolumn, yyline);}
    {WHILE}             {anuncio("WHILE"); 				return new Symbol(sym.WHILE, yycolumn, yyline);}
	{ID}				{anuncio("ID"); addSym(yytext(), "ID", null); return new Symbol(sym.ID, yycolumn, yyline, new String(yytext()));}
	
	{CTE_INT}			{
							anuncio("CTE_INT");					
							if (!checkInt(yytext())){	
								e.escribir("Lexema '" + yytext() + "' excede el valor maximo de un Integer (" + INT_MAX_LEN + ").\n", true);
							}
							else{
								addSym("_" + yytext(), "CTE_INT", yytext(), null);
								return new Symbol(sym.CTE_INT, yycolumn, yyline, new String(yytext()));
							}
						}
					
	{CTE_FLOAT}			{	anuncio("CTE_FLOAT");addSym("_" + yytext(), "CTE_FLOAT", yytext(), null); 
							return new Symbol(sym.CTE_FLOAT, yycolumn, yyline, new String(yytext()));}
						
	{CTE_STR}			{	anuncio("CTE_STR");
							if (!checkStr(yytext())){
								e.escribir("Lexema '" + yytext() + "' excede la longitud maxima de un String (" + STR_MAX_LEN + ").\n", true);		
							}
							else{
								addSym("_" + yytext(), "CTE_STR",  limpiarString(yytext()), limpiarString(yytext()).length());
								return new Symbol(sym.CTE_STRING, yycolumn, yyline, new String(yytext()));
							}
						}
	
	{COMENTARIO}		{/* no hacer nada */}
	{ESPACIO}			{/* no hacer nada*/ }
	{FIN_LINEA}			{/* no hacer nada*/ }
}


[^]	{ 
	e.escribir("Caracter no permitido: <" + yytext() + "> en la linea " + yyline + " columna " + yycolumn + ".", true);
	System.out.println("Caracter no permitido: <" + yytext() + "> en la linea " + yyline + " columna " + yycolumn + ".");
	throw new Error("Caracter no permitido: <" + yytext() + "> en la linea " + yyline + " columna " + yycolumn + "."); 
}

















