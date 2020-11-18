package compilador;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

public class Lectora {

/*
/home/nico/eclipse/eclipse-workspace/compilador/AAAAA.txt
/home/nico/unlu/00_teo_1/02_tps/teo1/tp9-integrador/entrega_1/00-prueba.txt
*/

	public static void analizar() throws FileNotFoundException, IOException{
		//		FileReader input_file = new FileReader("archivos/prueba.txt");
		FileReader input_file = new FileReader("archivos/prueba.txt");
		// Construyo un lexer con el archivo como argumento del constructor
		Lexico lexer = new Lexico(input_file);
		
		lexer.next_token();	
				
	}

}
