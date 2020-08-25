//
//  RegisterViewController.swift
//  BgPlatziTweets
//
//  Created by Bryan Andres Gomez Hernandez on 8/24/20.
//  Copyright © 2020 Bryan Andres Gomez Hernandez. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import SVProgressHUD
import Simple_Networking

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()

    }
    // MARK: - IBActions
    @IBAction func registerButtonAction(){
        view.endEditing(true)
        performRegister()
    }
    
    // MARK: - Private functions
    private func setUp(){
          registerButton.layer.cornerRadius = 25
    }
    
    private func performRegister(){
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo.", style: .warning).show()
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Ingresa la contraseña", style: .warning).show()
            return
        }
        
        guard let name = nameTextField.text, !name.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Ingresa el nombre y apellido", style: .warning).show()
            return
        }
        
        let request = RegisterRequest(email: email, password: password, names: name)
        
        //Iniciamos la carga
        SVProgressHUD.show()
        
        // Llamar libreria de red
        SN.post(endpoint: Endpoints.register, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            switch response {
            case .success( _):
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "showHome", sender: nil)
                return
            case .error(let error):
                NotificationBanner(subtitle: error.localizedDescription, style: .danger).show()
                SVProgressHUD.dismiss()
                return
            case .errorResult(let entity):
                NotificationBanner(subtitle: entity.error, style: .warning).show()
                SVProgressHUD.dismiss()
                return
            }
        }
        
        //performSegue(withIdentifier: "showHome", sender: nil)
    }
}
