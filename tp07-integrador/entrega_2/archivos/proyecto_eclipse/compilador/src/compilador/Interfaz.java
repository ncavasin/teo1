package compilador;


import java.awt.EventQueue;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.border.EmptyBorder;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.awt.event.ActionEvent;
import java.awt.Font;
import javax.swing.JTextPane;
import javax.swing.JLabel;

public class Interfaz extends JFrame {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private JPanel contentPane;
	
	JLabel lblCompilador = new JLabel("COMPILADOR");
	JLabel lblParse = new JLabel("Resultado de parsing:");
	JLabel lblTabla = new JLabel("No olvide revisar el archivo 'tabla_simbolos.txt'.");
	JLabel lblLexico = new JLabel("No olvide revisar el archivo 'analisis_lexico.txt'.");
	
	private static JTextPane textLex = new JTextPane();
	private JScrollPane textLexScrollable = new JScrollPane(textLex);
	private final JButton btnNewButton = new JButton("Analizar");
		
	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			@SuppressWarnings("deprecation")
			public void run() {

					Interfaz frame = new Interfaz();
					frame.setVisible(true);
					frame.setTitle("Compilador v2");
					
					//System.out.println("Path recibido: "+args[0]);
					// Verifico cantidad de argumentos
					if (args.length != 1) {
						
						System.out.println("!!! - Error: invocacion incorrecta.");
						System.out.println("Uso: java -jar compilador.jar <archivo_prueba.txt>");
						System.exit(-1);
					}
					
				    File file = new File("analisis_gramatico.txt");
				     
				    PrintStream stream;
					try {
						stream = new PrintStream(file);
						System.setOut(stream);
						System.setErr(stream);
					} catch (FileNotFoundException e1) {
						textLex.setText("Error creando el archivo 'analisis_gramatico.txt'");
						//e1.printStackTrace();
					}
				    
				       

					try {
						parser sintactico;
						sintactico = new parser(new Lexico(new FileReader(args[0])));
						sintactico.parse();
					} catch (FileNotFoundException e1) {
						textLex.setText("El archivo especificado no existe!");
						e1.printStackTrace();
					}
					catch (Exception e2) {
						textLex.setText("Ha ocurrido un error. Por favor revise la consola o el archivo 'analisis_lexico.txt'");
						e2.printStackTrace();
					}	

					// Muestro analisis sintactico
					mostrar("analisis_gramatico.txt", textLex);
			}
		});
	}

	/**
	 * Create the frame.
	 */
	public Interfaz() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(175, 100, 900, 500);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		setContentPane(contentPane);
		btnNewButton.setFont(new Font("Arial", Font.PLAIN, 12));
		btnNewButton.setBounds(340, 250, 80, 30);
		btnNewButton.setVisible(false);
		btnNewButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

			}
		});
		contentPane.setLayout(null);
		contentPane.add(btnNewButton);
		
		
		lblCompilador.setFont(new Font("Arial", Font.PLAIN, 30));
		lblCompilador.setBounds(350, 0, 200, 58);
		contentPane.add(lblCompilador);
				
		lblParse.setFont(new Font("Arial", Font.BOLD, 12));
		lblParse.setBounds(25, 35, 130, 50);
		contentPane.add(lblParse);
		
		textLex.setBounds(25 + (contentPane.getWidth()/2), 75, 840, 300);
		textLex.setEditable(false);

		textLexScrollable.setBounds(25 + (contentPane.getWidth()/2), 75, 840, 300);
		contentPane.add(textLexScrollable);
		
		lblTabla.setFont(new Font("Arial", Font.BOLD, 16));
		lblTabla.setBounds(25, 355, 600, 70);
		contentPane.add(lblTabla);		
		
		lblLexico.setFont(new Font("Arial", Font.BOLD, 16));
		lblLexico.setBounds(25, 400, 600, 70);
		contentPane.add(lblLexico);		
								
	}
	
	private static void mostrar(String path, JTextPane pane) {
		String s;
		try {
			s = new String(Files.readAllBytes(Paths.get(path)));

			pane.setText(s);
		} catch (IOException e) {
			e.printStackTrace();
		}		
	}
}
