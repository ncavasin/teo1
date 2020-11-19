package compilador;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TablaSimbolos {
	
	// Nombre de archivo
	public static final String FILENAME = "tabla_simbolos.txt";
	
	// Columnas de la tabla de simbolos
	public enum Columna {
		NOMBRE(1),
		TOKEN(2),
		TIPO(3),
		VALOR(4),
		LEN(5);
		
		private int numCol;
			
		private Columna(int numCol) {
			this.numCol = numCol;
		}
			
		public int getNumCol() {
			return numCol;
		}
			
			@Override
		public String toString() {
			return this.name();
		}
	}
	
	public static boolean escribirArchivo(List<Map<Columna, String>> lineas, String filename, boolean append) {
		if (filename == null || "".equals(filename)) filename = FILENAME;
		try (PrintWriter out = new PrintWriter(new FileWriter(filename, append))) {
			final String formato = "|%25s|%10s|%10s|%25s|%4s|";
			
			if (!append) {
				out.println(String.format(formato, Columna.NOMBRE, Columna.TOKEN, Columna.TIPO, Columna.VALOR, Columna.LEN));
				out.println("--------------------------------------------------------------------------------");
			}
			
			if (lineas != null)
				for (Map<Columna, String> linea : lineas) {
					String nombre = linea.get(Columna.NOMBRE) == null ? "" : linea.get(Columna.NOMBRE);
					String token = linea.get(Columna.TOKEN) == null ? "" : linea.get(Columna.TOKEN);
					String tipo = linea.get(Columna.TIPO) == null ? "" : linea.get(Columna.TIPO);
					String valor = linea.get(Columna.VALOR) == null ? "" : linea.get(Columna.VALOR);
					String len = linea.get(Columna.LEN) == null ? "" : linea.get(Columna.LEN);
					out.println(String.format(formato, nombre, token, tipo, valor, len));
				}
			
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		
		return true;
	}
	
	public static List<Map<Columna, String>> leerArchivo(String filename) {
		if (filename == null || "".equals(filename)) filename = FILENAME;
		List<Map<Columna, String>> filas = new ArrayList<Map<Columna, String>>();
		try (BufferedReader in = new BufferedReader(new FileReader(filename))) {
			in.readLine(); // Cabeceras
			in.readLine();
			String linea;
			while ((linea = in.readLine()) != null) {
				String[] splitLine = linea.split("\\|");
				Map<Columna, String> fila = new HashMap<Columna, String>();
				for (Columna c : Columna.values()) {
					fila.put(c, splitLine[c.getNumCol()].trim());
				}
				filas.add(fila);
			}
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		
		return filas;
	}
} 
