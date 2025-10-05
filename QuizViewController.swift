//
//  QuizViewController.swift
//  Oh-laline
//
//  Created by Victoria Ortega on 17/08/25.
//
import UIKit

class QuizViewController: UIViewController {
    
    @IBOutlet weak var opcionViajar: UIView!
    @IBOutlet weak var opcionEstudios: UIView!
    @IBOutlet weak var opcionTrabajo: UIView!
    @IBOutlet weak var opcionHobby: UIView!
    @IBOutlet weak var opcionExamen: UIView!
    @IBOutlet weak var opcionOtro: UIView!
    
    @IBOutlet weak var btnEntrar: UIButton!
    
    // Diccionario para relacionar cada opción con su "indicador"
    var indicadores: [Int: UIView] = [:]
    var opcionSeleccionadaTag: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar las opciones con sus gestos
        configurarOpcion(opcionViajar, tag: 1)
        configurarOpcion(opcionEstudios, tag: 2)
        configurarOpcion(opcionTrabajo, tag: 3)
        configurarOpcion(opcionHobby, tag: 4)
        configurarOpcion(opcionExamen, tag: 5)
        configurarOpcion(opcionOtro, tag: 6)
        
        // Botón deshabilitado al inicio
        btnEntrar.isEnabled = false
        btnEntrar.alpha = 0.5   // solo se ve atenuado, sin cambiar su color
        btnEntrar.layer.cornerRadius = 8
    }
    
    func configurarOpcion(_ vista: UIView, tag: Int) {
        vista.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(opcionSeleccionada(_:)))
        vista.addGestureRecognizer(tap)
        vista.tag = tag
        
        // Crear un indicador circular
        let indicador = UIView()
        indicador.translatesAutoresizingMaskIntoConstraints = false
        indicador.layer.cornerRadius = 12
        indicador.layer.borderWidth = 2
        indicador.layer.borderColor = UIColor(named: "principal")?.cgColor
        indicador.backgroundColor = .clear
        vista.addSubview(indicador)
        
        
        NSLayoutConstraint.activate([
            indicador.centerYAnchor.constraint(equalTo: vista.centerYAnchor, constant: -17),
            indicador.trailingAnchor.constraint(equalTo: vista.layoutMarginsGuide.trailingAnchor, constant: -20),
            indicador.widthAnchor.constraint(equalToConstant: 24),
            indicador.heightAnchor.constraint(equalToConstant: 24)
        ])

        
        indicadores[tag] = indicador
    }

    
    @objc func opcionSeleccionada(_ sender: UITapGestureRecognizer) {
        guard let vista = sender.view else { return }
        
        // Si tocas la misma opción y ya está seleccionada -> deselecciona
        if opcionSeleccionadaTag == vista.tag {
            indicadores[vista.tag]?.backgroundColor = .clear
            opcionSeleccionadaTag = nil
            btnEntrar.isEnabled = false
            btnEntrar.alpha = 0.5
            return
        }
        
        // Desmarcar todas las opciones
        for (_, indicador) in indicadores {
            indicador.backgroundColor = .clear
        }
        
        // Marcar la opción seleccionada con color principal
        if let indicador = indicadores[vista.tag] {
            indicador.backgroundColor = UIColor(named: "principal")
        }
        
        opcionSeleccionadaTag = vista.tag
        print("Opción seleccionada: \(vista.tag)")
        
        // Activar botón (recupera su color definido en storyboard)
        btnEntrar.isEnabled = true
        btnEntrar.alpha = 1.0
    }
    
    @IBAction func entrarTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "didFinishOnboarding")
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let mainTab = sb.instantiateViewController(withIdentifier: "MainTabBarVC")
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = mainTab
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
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

