//
//  LoginViewController.swift
//  Oh-laline
//
//  Created by Victoria Ortega on 18/08/25.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
    
    @IBAction func quizButton(_ sender: UIButton) {
        botonTouch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurarVista()
        
        //  Ocultar teclado al tocar fuera de los campos
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //  Escuchar cuando aparece y desaparece el teclado
        NotificationCenter.default.addObserver(self, selector: #selector(tecladoAparece(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tecladoDesaparece(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Recuperar último login guardado
        let yaHizoLogin = UserDefaults.standard.string(forKey: "inicioSesion") ?? ""
        if !(yaHizoLogin.isEmpty) {
            if let antes = df.date(from: yaHizoLogin) {
                let diff = antes.distance(to: Date())
                // Si han pasado menos de 5 min, ir directo al home
                if diff < 300 {
                    irAHome()
                } else {
                    mostrarAlerta("La sesión ha expirado, vuelve a iniciar sesión.")
                }
            }
        }
    }
    
    @objc func botonTouch() {
        var mensaje = ""
        
        if let correo = email.text,
           let pass = password.text {
            
            if correo.isEmpty || pass.isEmpty {
                mensaje = "Ambos campos son requeridos"
            } else {
                // Validación de email con RegEx
                let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                if !(emailTest.evaluate(with: correo)) {
                    mensaje = "Indique un correo válido"
                } else if pass.count < 6 {
                    mensaje = "La contraseña debe tener al menos 6 caracteres"
                }
            }
        }
        
        if mensaje.isEmpty {
            // Guardar la fecha/hora de login
            let hoy = Date()
            UserDefaults.standard.set(df.string(from: hoy), forKey: "inicioSesion")
            
            // Ir al home
            irAHome()
        } else {
            mostrarAlerta(mensaje)
        }
    }
    
    func irAHome() {
        // Si usas segue conectado en storyboard:
        performSegue(withIdentifier: "segueQuiz", sender: self)
    }
    
    func mostrarAlerta(_ mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
        let btnAceptar = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(btnAceptar)
        self.present(alert, animated: true, completion: nil)
    }
    
    func configurarVista() {
        email.placeholder = "Correo electrónico"
        password.placeholder = "Contraseña"
        
        email.autocapitalizationType = .none
        email.autocorrectionType = .no
        email.keyboardType = .emailAddress
        
        password.autocapitalizationType = .none
        password.autocorrectionType = .no
        password.isSecureTextEntry = true
    }
    
    //  MARK: - Manejo de teclado
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func tecladoAparece(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // Subir vista cuando aparece el teclado
            let alturaTeclado = keyboardFrame.height
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= alturaTeclado / 2
            }
        }
    }
    
    @objc func tecladoDesaparece(_ notification: Notification) {
        // Regresar la vista a su lugar
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
