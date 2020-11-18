package compilador;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

public class EscribeAnalisis{
 
	public static void escribir(String s, boolean append) {
		try(PrintWriter writer = new PrintWriter(new FileWriter("archivos/analisis.txt", append))){
			if(append) {
				writer.println(s);
			}
        } catch (IOException e) {
            e.printStackTrace();
        }
	 
	}
 	 
}

