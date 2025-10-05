import UIKit

class HomeViewController: UIViewController {

    // Conectar los botones desde el storyboard
    @IBOutlet weak var btnPhrases: UIButton!
    @IBOutlet weak var btnConjugaisons: UIButton!
    @IBOutlet weak var btnVerbes: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verificarConexionAntesDeContinuar {
                   print("El usuario está conectado.")
               }
        // Configurar bordes redondeados de todos los botones
        let botones = [btnPhrases, btnConjugaisons, btnVerbes]
        botones.forEach { button in
            button?.layer.cornerRadius = 20  // Cambia el número según tu gusto
            button?.clipsToBounds = true
        }
    }
    
    // MARK: - Acciones de botones
    
    @IBAction func btnPhrases(_ sender: UIButton) {
        animateButton(sender) {
            // Ejecuta el segue definido en el storyboard
            self.performSegue(withIdentifier: "seguePhrases", sender: self)
        }
    }
    
    @IBAction func btnConjugaisons(_ sender: UIButton) {
        animateButton(sender, completion: nil)
        // Aquí puedes agregar acción futura
    }
    
    @IBAction func btnVerbes(_ sender: UIButton) {
        animateButton(sender, completion: nil)
        // Aquí puedes agregar acción futura
    }
    
    // MARK: - Animación del botón
    func animateButton(_ button: UIButton, completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.2,
                       animations: {
            button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) // Agranda
        }) { _ in
            UIView.animate(withDuration: 0.1,
                           animations: {
                button.transform = CGAffineTransform.identity // Regresa a tamaño normal
            }, completion: { _ in
                completion?()
            })
        }
    }
    
    // MARK: - Preparar datos para el segue (si necesitas pasar algo)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueHome" {
        }
    }
}

