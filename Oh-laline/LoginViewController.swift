//
//  LoginViewController.swift
//  Oh-laline
//
//  Created by Victoria Ortega on 18/08/25.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
    
    // Contexto de Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
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
        
        // Cargar último login guardado en Core Data (opcional, si quieres mostrarlo en campos)
        cargarUltimoLogin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        verificarConexionAntesDeContinuar(startAction: {
                print("El usuario está conectado.")
            })
        
        // Recuperar último login guardado en UserDefaults
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
        
        print("🔵 botonTouch() ejecutado")
        
        if let correo = email.text,
           let pass = password.text {
            
            print("📝 Email: \(correo), Password: \(pass)")
            
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
            print("✅ Validaciones pasadas, guardando datos...")
            
            // Guardar la fecha/hora de login
            let hoy = Date()
            UserDefaults.standard.set(df.string(from: hoy), forKey: "inicioSesion")
            
            // Guardar en Core Data
            if let correo = email.text, let pass = password.text {
                print("🔄 Llamando a guardarLoginCoreData...")
                guardarLoginCoreData(email: correo, password: pass)
            }
            
            // Ir al home
            print("🏠 Llamando a irAHome...")
            irAHome()
        } else {
            print("❌ Error: \(mensaje)")
            mostrarAlerta(mensaje)
        }
    }
    
    func irAHome() {
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
    
    // MARK: - Manejo de teclado
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func tecladoAparece(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let alturaTeclado = keyboardFrame.height
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= alturaTeclado / 2
            }
        }
    }
    
    @objc func tecladoDesaparece(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - Core Data
    
    func guardarLoginCoreData(email: String, password: String) {
        print("💾 guardarLoginCoreData iniciado")
        print("📧 Email a guardar: \(email)")
        print("🔑 Password a guardar: \(password)")
        
        let nuevoUsuario = Login(context: context)
        nuevoUsuario.id_user = UUID()
        nuevoUsuario.email = email
        nuevoUsuario.password = password
        nuevoUsuario.dateLogin = Date()
        nuevoUsuario.motivationQuiz = 0
        nuevoUsuario.userPro = false

        do {
            try context.save()
            print("✅ Login guardado correctamente en Core Data")
        } catch {
            print("❌ Error al guardar login: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
        }

        // Mostrar todos los logins guardados en consola
        let request: NSFetchRequest<Login> = Login.fetchRequest()
        do {
            let logins = try context.fetch(request)
            print("📊 Total de logins en BD: \(logins.count)")
            for login in logins {
                print("🔹 Email: \(login.email ?? "") | Password: \(login.password ?? "") | Fecha: \(login.dateLogin ?? Date())")
            }
        } catch {
            print("❌ Error al leer logins: \(error)")
        }
    }
    
    
    
    func cargarUltimoLogin() {
        let request: NSFetchRequest<Login> = Login.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateLogin", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1
        
        do {
            let usuarios = try context.fetch(request)
            if let ultimo = usuarios.first {
                email.text = ultimo.email
                password.text = ultimo.password
            }
        } catch {
            print("Error al cargar último login: \(error)")
        }
    }
}
