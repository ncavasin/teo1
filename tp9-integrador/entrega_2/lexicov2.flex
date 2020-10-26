import java_cup.runtime.Symbol;


%%


/*%cupsym Simbolo*/
%cup
%public
%class Lexico
%line
%column
%char


 // ============================================================================

%{

	// Valores maximos
	private final int STR_MAX_LEN = 30
	private final Integer INT_MAX_LEN = 65536		/* 2¹⁶*/
	private final Float FLOAT_MAX_LEN = 4294967296 	/* 2³²*/
	
	
	// Tabla de simbolos: una lista con mapas en cada elemento de la lista
	// Cada mapa representa un simbolo e info asociada a este
	// Formato de cada mapa:  NOMBRE | TOKEN | TIPO | VALOR | LONGITUD
	private List<Map<Columna, String>> symTable;
	
	
	// Inicializo tabla de simbolos
	private void iniTable(){
		symTable = new List<Map<Columna, String>>();
	
	}
	
	
	// Agrega el token encontrado como simbolo
	public void addSymbol(){
	
	}
	
	// Verifica la cantidad de bits del integer (recibido como string)
	public boolean checkInt(String s){
		// Verifico que s no este vacia
		if (s.isEmpty()){
			return false;
		}
		try{
			// Parseo a integer
			Integer number = Integer.valueOf(s)
			// Verifico que no exceda el maximo valor
			if (number > INT_MAX_VALUE){
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
	public booolean checkFloat(String s){
		// Verifico que s no este vacia
		if (s.isEmpty()){
			return false;
		}
		try{
			// Parseo a float
			Float number = Float.valueOf(s)
			// Verifico que no exceda el maximo valor
			if (number > FLOAT_MAX_VALUE){
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
		System.out.println("***Nuevo hallazgo***")
		System.out.println("\tToken = " + token + ".\n\tLexema = " + yytext() + ".\n");
	}
	
%}


 // ============================================================================


FIN_LINEA = \r|\n|\r\n
ESPACIO = {FIN_LINEA}|\t|\f

DIGITO = [0-9]
LETRA = [a-zA-Z]
PUNTO = [.]

CHAR = {DIGITO}|{LETRA}|{ESPACIO}

COMILLA = \"

OPERADORES = \+|\-|\*|\/
OP_LOGICO = \<|\<\=|\=\=|\<\>|\>|\>\=|\&\&|\|\|

SEP_SENTENCIA = \;

BLOQUE_ABRE = \{
BLOQUE_CIERRA = \}

COMENTARIO = "</"[^"</"]*"/>"

// Longitud maxima de los ints es 16 bits
CONST_INT = 0 | [1-9]{DIGITO}*
	
// Longitud maxima de los floats es 32 bits
// Acepta: 12.12 / 12. / .12
CONST_FLOAT = {DIGITO}*{PUNTO}{DIGITO}+|{DIGITO}+{PUNTO}{DIGITO}*

// Longitud maxima de las strings es 30 chars
//CONST_STR = {COMILLA}({LETRA}|{DIGITO}|{ESPACIO})*{COMILLA}
CONST_STR = {COMILLA}{CHAR}*{COMILLA}

// Longitud maxima del nombre de variable es 30
ID_VAR = {LETRA}({LETRA}|{DIGITO}|\_)*

NUMERO = {CONST_INT}|{CONST_FLOAT}
EXPRESION = {NUMERO}|{CONST_STR}

VALOR = {ID_VAR}|{NUMERO}|{ID_VAR}{OPERADOR}{NUMERO}|{NUMERO}{OPERADOR}{NUMERO} 
ASIGNACION = {ID_VAR}":="{VALOR}



SENTENCIA = {IF}|{WHILE}|{PRINT}|{TAKE}|{ASIGNACION}{SEP_SENTENCIA}
CONTENIDO = {SENTENCIA}
BLOQUE = {BLOQUE_ABRE}{CONTENIDO}{BLOQUE_CIERRA}
CONDICION = \({EXPRESION}{OP_LOGICO}{EXPRESION}\) /* FALTA HACER QUE SE ANIDEN CONDICIONES */

IF = ([I][F]|[I][f]|[i][f])\({CONDICION}\){BLOQUE}
ELSE = ([E][L][S][E]|[E][l][s][e]|[e][l][s][e]){BLOQUE}

WHILE = ([W][H][I][L][E]|[W][h][i][l][e]|[w][h][i][l][e])\({CONDICION}\){BLOQUE}

PRINT = ([P][R][I][N][T]|[P][r][i][n][t]|[p][r][i][n][t]){CONST_STR}

TAKE_HEAD = [T][A][K][E]|[T][a][k][e]|[t][a][k][e]
TAKE = {TAKE_HEAD}\({OPERADORES}{ESPACIO}*";"{CONST_INT}{ESPACIO}*";"\[({CONST_INT}";")*\]\)


DECLARE = [D][E][C][L][A][R]E]
END_DECLARE = [E][N][D][D][E][C][L][A][R]E]

LISTA_DEC = \[A\]

DECLARACION = {DECLARE}{DECLARE_LEFT}":="{DECLARE_RIGHT}{END_DECLARE}

BEGIN_PROGRAM = [B][E][G][I][N]{PUNTO}[P][R][O][G][R][A][M]
END_PROGRAM = [E][N][D]{PUNTO}[P][R][O][G][R][A][M]

PROGRAMA = {DECLARACION}{BEGIN_PROGRAM}{CONTENIDO}{END_PROGRAM}|{BEGIN_PROGRAM}{CONTENIDO}{END_PROGRAM}

%%

<YYINITIAL> {
	
	{ASIGNACION}			{anuncio("ASIGNACION");}
	{BEGIN_PROGRAM}			{anuncio("BEGIN.PROGRAM");iniTable();}
	{END_PROGRAM}			{anuncio("END.PROGRAM");}
	
	{DECLARE}				{anuncio("DECLARE");}
	{END_DECLARE}			{anuncio("ENDDECLARE");}

	{IF}					{anuncio("IF");}
	{ELSE}					{anuncio("ELSE");}
	
	{WHILE}					{anuncio("WHILE");}
	
	{PRINT}					{anuncio("PRINT");}
	
	{TAKE}					{anuncio("TAKE");}
	
	{ID_VAR}				{anuncio("ID_VAR");}
	
							// Aseguro longitud valida
	{CONST_INT}				{
								if !(checkInt(yytext())){
									System.out.println("Lexema " + yytext() + " excede el valor máximo de un Integer (" + INT_MAX_LEN + ").");	
								}
								else{
									anuncio("CONST_INT");
								}
							}		
					
							// Aseguro longitud valida
	{CONST_FLOAT}			{
								if !(checkFloat(yytext())){
									System.out.println("Lexema " + yytext() + " excede el valor máximo de un Float (" + FLOAT_MAX_LEN + ").");	
								}
								else{
									anuncio("CONST_FLOAT");
								}
							}
					
							// Aseguro longitud valida
	{CONST_STR}				{
								if !(checkStr(yytext())){
									System.out.println("Lexema " + yytext() + " excede la longitud maxima de un String (" + STR_MAX_LEN + ").");		
								}
								else{
									anuncio("CONST_STR");
								}
							}
			
	{COMENTARIO}			{/* se ignora el contenido */}
	{ESPACIO}				{/* no hacer nada */}
}


[^]	{ 
	throw new Error("Caracter no permitido: <" + yytext() + "> en la linea " + yyline + " columna " + yycolumn + "."); 
}
























