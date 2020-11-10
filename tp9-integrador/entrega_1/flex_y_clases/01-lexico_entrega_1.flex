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
	/* 2³² */
	private final float FLOAT_MAX_LEN = 0;
	
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


CONST_INT = {DIGITO}|{DIGITO}+
CONST_FLOAT = {DIGITO}*{PUNTO}{DIGITO}+ | {DIGITO}+{PUNTO}{DIGITO}*
CONST_STR = {COMILLA} [^\"]* {COMILLA} | \' [^\']* \'

INT = [I][N][T]|[I][n][t]|[i][n][t]
FLOAT = [F][L][O][A][T]|[F][l][o][a][t]|[f][l][o][a][t]
STRING =  [S][T][R][I][N][G]|[S][t][r][i][n][g]|[s][t][r][i][n][g]

TIPO_DATO = {INT}|{FLOAT}|{STRING}

IF = [I][F]|[I][f]|[i][f]
ELSE = [E][L][S][E]|[E][l][s][e]|[e][l][s][e]

WHILE = [W][H][I][L][E]|[W][h][i][l][e]|[w][h][i][l][e]

PRINT = [P][R][I][N][T]|[P][r][i][n][t]|[p][r][i][n][t]

TAKE = [T][A][K][E]|[T][a][k][e]|[t][a][k][e]

COMEN_ABRE = \<\/
COMEN_CIERRA = \/\>
COMENTARIO = {COMEN_ABRE}[^(\/>)]*{COMEN_CIERRA}|{COMEN_ABRE}{COMEN_CIERRA}

ID_VAR = {LETRA}({LETRA}|{DIGITO}|\_)*

%%

<YYINITIAL> {
    "BEGIN.PROGRAM"		{anuncio("BEGIN.PROGRAM");}
    "END.PROGRAM"		{anuncio("END.PROGRAM");}
    "DECLARE"           {anuncio("DECLARE");iniTable();}
    "ENDDECLARE"		{anuncio("ENDDECLARE");}
    {TAKE}				{anuncio("TAKE");}
    {PRINT}             {anuncio("PRINT");}
    {IF}                {anuncio("IF");}
    {ELSE}              {anuncio("ELSE");}
    {WHILE}             {anuncio("WHILE");}
    {TIPO_DATO}			{anuncio("TIPO_DATO");}
	"="                	{anuncio("ASIGNA");}
    "=="                {anuncio("IGUAL");}
    "<>"                {anuncio("DISTINTO");} 
    "<"	                {anuncio("MENOR");}
    "<="                {anuncio("MENOR_IGUAL");}
    ">"                 {anuncio("MAYOR");}
    ">="                {anuncio("MAYOR_IGUAL");}
    "&&"				{anuncio("AND");}
    "||"				{anuncio("OR");}
    "+"                 {anuncio("SUMA");}
    "-"		            {anuncio("RESTA");}
    "/"                 {anuncio("DIVIDE");}
    "*"                 {anuncio("MULTIPLICA");}
    "("                 {anuncio("PAR_ABRE");}
	")"                 {anuncio("PAR_CIERRA");}
    "{"                 {anuncio("LLAVE_ABRE");}
    "}"                 {anuncio("LLAVE_CIERRA");}  
    "["                 {anuncio("COR_ABRE");}  
    "]"                 {anuncio("COR_CIERRA");}  
    ";"                 {anuncio("PUNTO_COMA");}
    ","                 {anuncio("COMA");}
    
	{ID_VAR}			{anuncio("ID_VAR"); addSym(yytext(), "ID_VAR", null);}
	
	{CONST_INT}			{
							anuncio("CONST_INT");					
							if (!checkInt(yytext())){
								System.out.println("Lexema " + yytext() + " excede el valor maximo de un Integer (" + INT_MAX_LEN + ").\n");	
							}
							else{
								addSym("_" + yytext(), "CONST_INT", yytext(), null);
							}
						}
					
	{CONST_FLOAT}		{
							anuncio("CONST_FLOAT");
							if (!checkFloat(yytext())){
								System.out.println("Lexema " + yytext() + " excede el valor maximo de un Float (" + FLOAT_MAX_LEN + ").\n");	
							}
							else{
								addSym("_" + yytext(), "CONST_FLOAT", yytext(), null);
							}
						}
						
	{CONST_STR}			{
							anuncio("CONST_STR");
							if (!checkStr(yytext())){
								System.out.println("Lexema " + yytext() + " excede la longitud maxima de un String (" + STR_MAX_LEN + ").\n");		
							}
							else{
								addSym("_" + yytext(), "CONST_STR", yytext(), yytext().length());
							}
						}
	
	{COMENTARIO}		{anuncio("COMENTARIO");}
	{ESPACIO}			{/* no hacer nada */}
}


[^]	{ 
	throw new Error("Caracter no permitido: <" + yytext() + "> en la linea " + yyline + " columna " + yycolumn + "."); 
}

















