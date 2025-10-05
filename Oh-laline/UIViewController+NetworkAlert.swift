//
//  UIViewController+NetworkAlert.swift
//  Oh-laline
//
//  Created by Victoria Ortega on 04/10/25.
//

import UIKit

extension UIViewController {
    func verificarConexionAntesDeContinuar(startAction: @escaping () -> Void) {
        let monitor = NetworkMonitor.shared

        //  Sin conexión
        if !monitor.isConnected {
            let alert = UIAlertController(
                title: "Sin conexión a internet",
                message: "No estás conectado a ninguna red. Algunos datos no se podrán guardar. ¿Deseas continuar usando datos móviles si se activan?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            alert.addAction(UIAlertAction(title: "Continuar", style: .default) { _ in
                startAction()
            })
            present(alert, animated: true)
            return
        }

        //Está en datos móviles
        if monitor.connectionType == .cellular {
            let alert = UIAlertController(
                title: "Conexión con datos móviles",
                message: "Estás usando datos móviles. ¿Deseas continuar?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            alert.addAction(UIAlertAction(title: "Continuar", style: .default) { _ in
                startAction()
            })
            present(alert, animated: true)
            return
        }

        // Conectado por Wi-Fi, continuar directamente
        startAction()
    }
}

