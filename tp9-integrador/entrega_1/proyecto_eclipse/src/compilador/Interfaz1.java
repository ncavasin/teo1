package compilador;


import java.awt.EventQueue;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.io.FileReader;
import java.io.IOException;
import java.awt.event.ActionEvent;
import javax.swing.JTextField;
import java.awt.Font;
import javax.swing.JTextPane;
import javax.swing.JLabel;

public class Interfaz1 extends JFrame {

	private JPanel contentPane;
	JLabel lblCompilador = new JLabel("COMPILADOR");
	JLabel lblPath = new JLabel("Path prueba:");
	private JTextField textPath = new JTextField("archivos/prueba.txt");
	private JTextPane textLex = new JTextPane();
	private final JButton btnNewButton = new JButton("Analizar");
	private Lectora lectora;
	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					Interfaz1 frame = new Interfaz1();
					frame.setVisible(true);

				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * Create the frame.
	 */
	public Interfaz1() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 437, 317);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		setContentPane(contentPane);
		btnNewButton.setFont(new Font("Arial", Font.PLAIN, 12));
		btnNewButton.setBounds(340, 250, 80, 30);
		btnNewButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				String out = new String();
				try{
					
					Lectora.analizar();
					out = "Analisis finalizado.";
					out += "\nRevisa la tabla de simbolos en el archivo 'tabla_simbolos.txt'.";
					out += "\nRevisa el analisis lexico en el archivo 'analisis.txt' o chequea la salida por consola.";
					out += "\n\nSi desea cambiar la prueba, coloque un archivo llamado 'prueba.txt' en el directorio 'archivos/' "+
							"o copie y pegue sobre el ya existente.";
				} catch (IOException e1) {
					System.out.println("Error. Archivo no encontrado.");
					out = "Error. Archivo no encontrado. Ingrese path completo.";
					e1.toString();
				}
				
				textLex.setText(out);

			}
		});
		contentPane.setLayout(null);
		contentPane.add(btnNewButton);
		
		
		lblCompilador.setFont(new Font("Arial", Font.PLAIN, 30));
		lblCompilador.setBounds(115, 0, 242, 58);
		contentPane.add(lblCompilador);
		
		
		
		lblPath.setFont(new Font("Arial", Font.PLAIN, 12));
		lblPath.setBounds(12, 63, 90, 40);
		contentPane.add(lblPath);
		
		textPath.setBounds(100, 74, 320, 22);
		contentPane.add(textPath);
		textPath.setColumns(10);
		
		
		textLex.setBounds(22, 114, 398, 126);
		contentPane.add(textLex);
	}
}
