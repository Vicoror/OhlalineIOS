//
//  PhrasesViewController.swift
//  Oh-laline
//
//  Created by Victoria Ortega on 02/10/25.
//
//
//  PhrasesViewController.swift
//  Oh-laline
//
//  Created by Victoria Ortega on 02/10/25.
//
import UIKit

// MARK: - Modelos
struct Phrase: Codable {
    let numfrase: Int
    let nivel: String
    let tipo: String
    let fraseFr: String
    let fraseEs: String
    let categoria: String
}

struct PhrasesResponse: Codable {
    let frases: [Phrase]
}

// MARK: - ViewController
class PhrasesViewController: UIViewController {
    
    @IBOutlet weak var viewMsgPrincipal: UIView!
    @IBOutlet weak var labelMsgPrincipal: UILabel!
    @IBOutlet weak var btnMsgPrincipal: UIButton!
    
    // Scroll general
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Vistas de la parte superior (fijas)
    private let topBar = UIView()
    private let livesIcon = UIImageView()
    private let livesLabel = UILabel()
    private let titleLabel = UILabel()
    
    // Contenedor vertical para filas de "botes"
    private let macaroniStack = UIStackView()
    
    // Configs
    private let jarSize: CGFloat = 100
    private let rowHeight: CGFloat = 120
    private let sidePadding: CGFloat = 16
    
    // Datos de frases organizadas en bloques de 10
    private var phrasesData: [[Phrase]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "PrincipalExtraLight")
        
        // Configurar el mensaje principal PRIMERO
        setupMsgPrincipalView()
        
        // Agregar gesto para cerrar el mensaje al tocar fuera
        let tap = UITapGestureRecognizer(target: self, action: #selector(ocultarMensaje(_:)))
        tap.delegate = self // 👈 muy importante
        view.addGestureRecognizer(tap)
        
        loadPhrasesData()
        setupTopBar()
        setupScroll()
        setupMacaroniStack()
    }
    
    // MARK: - Función para ocultar mensaje al tocar fuera
    @objc func ocultarMensaje(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !viewMsgPrincipal.frame.contains(location) {
            viewMsgPrincipal.isHidden = true
        }
    }
    
    private func setupMsgPrincipalView() {
        viewMsgPrincipal.layer.cornerRadius = 16
        viewMsgPrincipal.layer.borderWidth = 2
        viewMsgPrincipal.layer.borderColor = UIColor(named: "principal")?.cgColor
        viewMsgPrincipal.backgroundColor = .white
        viewMsgPrincipal.isHidden = true
        viewMsgPrincipal.translatesAutoresizingMaskIntoConstraints = false
        
        // 🔹 Asegurar que esté en la parte superior de la jerarquía de vistas
        view.bringSubviewToFront(viewMsgPrincipal)
        
        // Centrar dentro del ViewController
        NSLayoutConstraint.activate([
            viewMsgPrincipal.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewMsgPrincipal.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            viewMsgPrincipal.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            viewMsgPrincipal.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Centrar label y botón dentro del view
        labelMsgPrincipal.translatesAutoresizingMaskIntoConstraints = false
        btnMsgPrincipal.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelMsgPrincipal.centerXAnchor.constraint(equalTo: viewMsgPrincipal.centerXAnchor),
            labelMsgPrincipal.topAnchor.constraint(equalTo: viewMsgPrincipal.topAnchor, constant: 30),
            labelMsgPrincipal.leadingAnchor.constraint(greaterThanOrEqualTo: viewMsgPrincipal.leadingAnchor, constant: 16),
            labelMsgPrincipal.trailingAnchor.constraint(lessThanOrEqualTo: viewMsgPrincipal.trailingAnchor, constant: -16),
            
            btnMsgPrincipal.centerXAnchor.constraint(equalTo: viewMsgPrincipal.centerXAnchor),
            btnMsgPrincipal.topAnchor.constraint(equalTo: labelMsgPrincipal.bottomAnchor, constant: 20),
            btnMsgPrincipal.widthAnchor.constraint(equalToConstant: 120),
            btnMsgPrincipal.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        btnMsgPrincipal.layer.cornerRadius = 10
        btnMsgPrincipal.backgroundColor = UIColor(named: "principal")
        btnMsgPrincipal.setTitleColor(.white, for: .normal)
        btnMsgPrincipal.addTarget(self, action: #selector(btnMsgPrincipalTapped(_:)), for: .touchUpInside)
    }

    
    // MARK: - Animación y segue del botón
    @objc private func btnMsgPrincipalTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
                       animations: {
                           sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.1,
                                          animations: {
                                              sender.transform = .identity
                                          },
                                          completion: { _ in
                                              self.irAPhrasesEx1()
                                          })
                       })
    }
    
    // MARK: - Navegación al siguiente VC
    @objc private func irAPhrasesEx1() {
        // Crea el ViewController manualmente desde el Storyboard
        if let phrasesEx1VC = storyboard?.instantiateViewController(withIdentifier: "PhrasesEx1ViewController") {
            // En lugar de present modally, hacer push al navigation controller
            navigationController?.pushViewController(phrasesEx1VC, animated: true)
        } else {
            print("Error: No se pudo encontrar PhrasesEx1ViewController en el Storyboard")
        }
    }
    
    // MARK: - Cargar datos de frases
    private func loadPhrasesData() {
        guard let url = Bundle.main.url(forResource: "frases", withExtension: "json") else {
            print("No se encontró el archivo frases.json")
            loadFallbackData()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(PhrasesResponse.self, from: data)
            let allPhrases = response.frases
            
            phrasesData = stride(from: 0, to: allPhrases.count, by: 10).map {
                Array(allPhrases[$0..<min($0 + 10, allPhrases.count)])
            }
            
            print("Cargadas \(allPhrases.count) frases en \(phrasesData.count) bloques")
        } catch {
            print("Error cargando JSON: \(error)")
            loadFallbackData()
        }
    }
    
    private func loadFallbackData() {
        phrasesData = []
    }
    
    // MARK: - Top bar (fija)
    private func setupTopBar() {
        topBar.backgroundColor = UIColor.systemGray6
        topBar.layer.cornerRadius = 20
        topBar.layer.masksToBounds = true
        topBar.layer.borderWidth = 1
        topBar.layer.borderColor = UIColor(named: "principal")?.cgColor
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            topBar.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        livesIcon.image = UIImage(named: "macaron_C5A4DA")
        livesIcon.contentMode = .scaleAspectFit
        livesIcon.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(livesIcon)
        
        livesLabel.text = "5"
        livesLabel.font = UIFont.boldSystemFont(ofSize: 20)
        livesLabel.textColor = .black
        livesLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(livesLabel)
        
        titleLabel.text = "Phrases"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            livesIcon.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 12),
            livesIcon.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            livesIcon.widthAnchor.constraint(equalToConstant: 28),
            livesIcon.heightAnchor.constraint(equalToConstant: 28),
            
            livesLabel.leadingAnchor.constraint(equalTo: livesIcon.trailingAnchor, constant: 8),
            livesLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])
        
        // 🔹 Asegurar que viewMsgPrincipal esté sobre la topBar
        view.bringSubviewToFront(viewMsgPrincipal)
    }
    
    // MARK: - Scroll setup
    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.alwaysBounceVertical = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        // 🔹 Asegurar que viewMsgPrincipal esté sobre el scrollView
        view.bringSubviewToFront(viewMsgPrincipal)
    }
    
    // MARK: - Macaroni Stack setup
    private func setupMacaroniStack() {
        macaroniStack.axis = .vertical
        macaroniStack.alignment = .fill
        macaroniStack.distribution = .equalSpacing
        macaroniStack.spacing = 12
        macaroniStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(macaroniStack)
        
        NSLayoutConstraint.activate([
            macaroniStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            macaroniStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding),
            macaroniStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding),
            macaroniStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        for i in 1...12 {
            let rowView = UIView()
            rowView.translatesAutoresizingMaskIntoConstraints = false
            rowView.heightAnchor.constraint(equalToConstant: rowHeight).isActive = true
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            rowView.addSubview(containerView)
            
            let jar = UIImageView()
            jar.image = UIImage(named: "macaron.svg\(i)")
            jar.contentMode = .scaleAspectFit
            jar.translatesAutoresizingMaskIntoConstraints = false
            jar.widthAnchor.constraint(equalToConstant: jarSize).isActive = true
            jar.heightAnchor.constraint(equalToConstant: jarSize).isActive = true
            jar.isUserInteractionEnabled = true
            
            containerView.addSubview(jar)
            
            let isActive = i == 1
            if isActive {
                jar.alpha = 1.0
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                jar.addGestureRecognizer(tapGesture)
                jar.tag = i - 1
            } else {
                jar.alpha = 0.4
                jar.isUserInteractionEnabled = false
            }
            
            let index = (i - 1) % 4
            switch index {
            case 0:
                NSLayoutConstraint.activate([
                    containerView.centerXAnchor.constraint(equalTo: rowView.centerXAnchor),
                    containerView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
                ])
            case 1:
                NSLayoutConstraint.activate([
                    containerView.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -8),
                    containerView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
                ])
            case 2:
                NSLayoutConstraint.activate([
                    containerView.centerXAnchor.constraint(equalTo: rowView.centerXAnchor),
                    containerView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
                ])
            case 3:
                NSLayoutConstraint.activate([
                    containerView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 8),
                    containerView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
                ])
            default: break
            }
            
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(equalToConstant: jarSize),
                containerView.heightAnchor.constraint(equalToConstant: jarSize)
            ])
            
            macaroniStack.addArrangedSubview(rowView)
        }
        
        // 🔹 Asegurar que viewMsgPrincipal esté sobre TODO
        view.bringSubviewToFront(viewMsgPrincipal)
    }
    
    // MARK: - Mostrar viewMsgPrincipal
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.25) {
                imageView.transform = .identity
            }
        }
        
        // Mostrar viewMsgPrincipal
        labelMsgPrincipal.text = "¡Vamos con las frases del bloque \(imageView.tag + 1)! 🇫🇷"
        viewMsgPrincipal.alpha = 0
        viewMsgPrincipal.isHidden = false
        
        // 🔹 Traer al frente una vez más antes de mostrar
        view.bringSubviewToFront(viewMsgPrincipal)
        
        UIView.animate(withDuration: 0.3) {
            self.viewMsgPrincipal.alpha = 1
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

// MARK: - UIGestureRecognizerDelegate
extension PhrasesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Ignorar taps dentro de viewMsgPrincipal (incluyendo el botón)
        if touch.view?.isDescendant(of: viewMsgPrincipal) == true {
            return false
        }
        return true
    }
}
