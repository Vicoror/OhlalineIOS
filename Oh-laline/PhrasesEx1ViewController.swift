//
//  PhrasesEx1ViewController.swift
//  Oh-laline
//
//  Created by Victoria Ortega on 03/10/25.
//

import UIKit

class PhrasesEx1ViewController: UIViewController {
    
    @IBOutlet weak var btnSuivant: UIButton!
    
    // MARK: - Propiedades
    private var phrases: [Phrase] = []
    private var currentIndex = 0
    
    // Componentes UI
    private let topBar = UIView()
    private let livesStack = UIStackView()
    
    private let fraseFrLabel = UILabel()
    private let fraseEsLabel = UILabel()
    
    // MARK: - Ciclo de vida
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "PrincipalExtraLight")
        
        setupTopBar()
        setupFrasesLabels()
        setupButton()
        loadPhrasesData()
        mostrarFraseActual()
        
        // Habilitar gesto para ir hacia atrás
        enableSwipeBack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ocultar tab bar
        tabBarController?.tabBar.isHidden = true
        
        // Ocultar barra de navegación
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Mostrar tab bar al salir
        tabBarController?.tabBar.isHidden = false
        
        // Mostrar barra de navegación al salir
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Habilitar gesto para ir hacia atrás (frase anterior)
    private func enableSwipeBack() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeBack))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeForward))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)
    }
    
    @objc private func handleSwipeBack(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            irAFraseAnterior()
        }
    }
    
    @objc private func handleSwipeForward(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            btnSuivantTapped(btnSuivant)
        }
    }
    
    private func irAFraseAnterior() {
        if currentIndex > 0 {
            currentIndex -= 1
            mostrarFraseActual()
            
            // Animación para feedback visual
            UIView.animate(withDuration: 0.3) {
                self.fraseFrLabel.alpha = 0
                self.fraseEsLabel.alpha = 0
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.fraseFrLabel.alpha = 1
                    self.fraseEsLabel.alpha = 1
                }
            }
        }
    }
    
    // MARK: - Top Bar con 5 vidas y botón de salir (X)
    private func setupTopBar() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topBar.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Botón de salir (X) en la parte izquierda superior
        let exitButton = UIButton(type: .system)
        exitButton.setTitle("×", for: .normal)
        exitButton.setTitleColor(UIColor(named: "principal"), for: .normal)
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .regular)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        topBar.addSubview(exitButton)
        
        // Configurar el stack de vidas
        livesStack.axis = .horizontal
        livesStack.distribution = .equalSpacing
        livesStack.alignment = .center
        livesStack.spacing = 8
        livesStack.translatesAutoresizingMaskIntoConstraints = false
        
        topBar.addSubview(livesStack)
        
        NSLayoutConstraint.activate([
            // Botón salir (X) - parte izquierda superior
            exitButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 10),
            exitButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 40),
            exitButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Stack de vidas - centrado
            livesStack.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            livesStack.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            livesStack.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Colores de macarons (vidas)
        let macarons = ["macaron_C5A4DA", "macaron_FFFA9C", "macaron_8CD5C9", "macaron_FF8A80", "macaron_D4E9F8"]
        
        for macaronName in macarons {
            let lifeImage = UIImageView(image: UIImage(named: macaronName))
            lifeImage.contentMode = .scaleAspectFit
            lifeImage.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                lifeImage.widthAnchor.constraint(equalToConstant: 35),
                lifeImage.heightAnchor.constraint(equalToConstant: 35)
            ])
            livesStack.addArrangedSubview(lifeImage)
        }
    }
    
    @objc private func exitButtonTapped() {
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            // Si está en un navigation stack, hacer pop
            navigationController.popViewController(animated: true)
        } else {
            // Si se presentó modalmente, hacer dismiss
            dismiss(animated: true)
        }
    }
    
    // MARK: - Labels de frases (centrados)
    private func setupFrasesLabels() {
        fraseFrLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        fraseFrLabel.textColor = .black
        fraseFrLabel.numberOfLines = 0
        fraseFrLabel.textAlignment = .center
        fraseFrLabel.translatesAutoresizingMaskIntoConstraints = false
        
        fraseEsLabel.font = UIFont.systemFont(ofSize: 20)
        fraseEsLabel.textColor = .darkGray
        fraseEsLabel.numberOfLines = 0
        fraseEsLabel.textAlignment = .center
        fraseEsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(fraseFrLabel)
        view.addSubview(fraseEsLabel)
        
        NSLayoutConstraint.activate([
            // Centrar verticalmente las frases en la pantalla
            fraseFrLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            fraseFrLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fraseFrLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            fraseEsLabel.topAnchor.constraint(equalTo: fraseFrLabel.bottomAnchor, constant: 20),
            fraseEsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fraseEsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Botón siguiente
    private func setupButton() {
        btnSuivant.setTitle("Suivant", for: .normal)
        btnSuivant.setTitleColor(.black, for: .normal)
        btnSuivant.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btnSuivant.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(btnSuivant)
        
        NSLayoutConstraint.activate([
            btnSuivant.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnSuivant.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            btnSuivant.widthAnchor.constraint(equalToConstant: 150),
            btnSuivant.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        btnSuivant.addTarget(self, action: #selector(btnSuivantTapped), for: .touchUpInside)
    }
    
    // MARK: - Cargar frases desde JSON
    private func loadPhrasesData() {
        guard let url = Bundle.main.url(forResource: "frases", withExtension: "json") else {
            print("No se encontró el archivo frases.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(PhrasesResponse.self, from: data)
            phrases = response.frases
        } catch {
            print("Error cargando frases.json: \(error)")
        }
    }
    
    // MARK: - Mostrar frase actual
    private func mostrarFraseActual() {
        guard currentIndex < phrases.count else { return }
        let frase = phrases[currentIndex]
        fraseFrLabel.text = frase.fraseFr
        fraseEsLabel.text = frase.fraseEs
    }
    
    // MARK: - Acción del botón
    @objc private func btnSuivantTapped(_ sender: UIButton) {
        // Cambiar color de fondo al dar clic - versión corregida
        let originalColor = sender.backgroundColor
        sender.backgroundColor = UIColor(named: "PrincipalLight")
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut) {
            sender.backgroundColor = originalColor
        }
        
        // Animación de transición
        UIView.animate(withDuration: 0.3) {
            self.fraseFrLabel.alpha = 0
            self.fraseEsLabel.alpha = 0
        } completion: { _ in
            // Mostrar la siguiente frase
            if self.currentIndex < 9 {
                self.currentIndex += 1
                self.mostrarFraseActual()
            } else {
                // Llegó al final del bloque (10 frases)
                let alert = UIAlertController(title: "¡Bien hecho!",
                                              message: "Has completado las 10 frases 🎉",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
                self.present(alert, animated: true)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.fraseFrLabel.alpha = 1
                self.fraseEsLabel.alpha = 1
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
// 🔹 ESTO DEBE ESTAR FUERA DE LA CLASE, AL FINAL DEL ARCHIVO
extension PhrasesEx1ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
