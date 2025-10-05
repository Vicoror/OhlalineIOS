//
//  ViewController.swift
//  Oh-laline
//
//  Created by Victoria Ortega on 17/08/25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginButton(_ sender: UIButton) {
        print("Tap al botón")
        performSegue(withIdentifier: "seguelogin", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.setTitle(NSLocalizedString("login_email_button", comment: "Connectez-vous avec votre e-mail"), for: .normal)
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguelogin" {
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        verificarConexionAntesDeContinuar {
            print("El usuario está conectado.")
            // Aquí el código que debe continuar si hay conexión
        }
    }
}
