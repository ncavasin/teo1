package compilador;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;


public class EscribeAnalisis{
	
	private final String path;
	
	public EscribeAnalisis(String path) {
		this.path = path;
	}
	
	public void escribir(String s, boolean append) {
		try(PrintWriter writer = new PrintWriter(new FileWriter(path, append))){
			if(append) {
				writer.println(s);
			}
        } catch (IOException e) {
            e.printStackTrace();
        }
	 
	}
 	 
}

