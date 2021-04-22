//
//  LoginViewController.swift
//  GithubExplorer-Pingthis
//
//  Created by SathishKumar on 21/04/21.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {
    
    var loginButton = UIButton.init(type: .roundedRect)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupLoginButton()
    }

    func setupLoginButton() {
        self.loginButton.setTitle("Github Login", for: .normal)
        self.loginButton.backgroundColor = .black
        self.loginButton.setTitleColor(.white, for: .normal)
        self.loginButton.addTarget(self, action: #selector(performLogin), for: .touchUpInside)
        self.loginButton.layer.cornerRadius = 25
        
        self.view.addSubview(self.loginButton)
        self.loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loginButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.loginButton.widthAnchor.constraint(equalToConstant: 200),
            self.loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func performLogin() {
        NetworkRequest.main.performLogin(contextProvider: self) { (isSuccessful) in
            DispatchQueue.main.async {
                if isSuccessful {
                    let homeViewController = HomeViewController.init()
                    let navController = UINavigationController.init(rootViewController: homeViewController)
                    navController.modalPresentationStyle = .fullScreen
                    self.view.window?.rootViewController = navController
                }
            }
        }
    }
}

extension LoginViewController : ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        return window ?? ASPresentationAnchor()
    }
}

