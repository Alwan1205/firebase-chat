//
//  AlertManager.swift
//  Firebase Chat
//
//  Created by Admin on 17/2/22.
//

import UIKit

final class AlertManager {
    
    static let shared = AlertManager()
    
}

extension AlertManager {
    
    public func presentInfoAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    public func presentInfoAlertWithCompletion(title: String, message: String, viewController: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion()
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // file: # file, function: $function, line: #line
    public func presentErrorAlert(file: String, function: String, line: Int, title: String, error: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: "File: \(file) - Function: \(function) - Line: \(String(line)) - Error: \(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
