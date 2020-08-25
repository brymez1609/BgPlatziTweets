//
//  LoginViewController.swift
//  BgPlatziTweets
//
//  Created by Bryan Andres Gomez Hernandez on 8/24/20.
//  Copyright © 2020 Bryan Andres Gomez Hernandez. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonAction(){
        performLogin()
    }
    
    // MARK: - Private functions
    private func setUp(){
        loginButton.layer.cornerRadius = 25
    }
    
    private func performLogin(){
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo.", style: .warning).show()
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Ingresa la contraseña", style: .warning).show()
            return
        }
        // Crear request.
        let request = LoginRequest(email: email, password: password)
        
        //Iniciamos la carga
        SVProgressHUD.show()
        
        // Llamar libreria de red
        SN.post(endpoint: Endpoints.login, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            switch response {
            case .success(let user):
                SVProgressHUD.dismiss()
                SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
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
        
    }
    
}
