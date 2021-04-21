//
//  NetworkRequest.swift
//  GithubExplorer-Pingthis
//
//  Created by SathishKumar on 21/04/21.
//

import Foundation
import AuthenticationServices

class NetworkRequest {
    
    static let main = NetworkRequest.init()
    
    private let callbackURLScheme = "githubexplore"
    private let clientID = "Iv1.c6a2aab38b6147f3"
    private let clientSecret = "de6dffa20ac858c9d034154a943b7bee9bf1cdcd"
    
    var accessToken : String? = UserDefaults.standard.string(forKey: "access_token") ?? nil {
        didSet {
            UserDefaults.standard.setValue(self.accessToken, forKey: "access_token")
        }
    }
    var refreshToken : String? = UserDefaults.standard.string(forKey: "refresh_token") ?? nil {
        didSet {
            UserDefaults.standard.setValue(self.refreshToken, forKey: "refresh_token")
        }
    }
    var userName : String? = UserDefaults.standard.string(forKey: "user_name") ?? nil {
        didSet {
            UserDefaults.standard.setValue(self.userName, forKey: "user_name")
        }
    }
    
    private init() {
        
    }
    
    func isLoggedIn() -> Bool {
        if self.userName != nil && self.accessToken != nil {
            return true
        }
        return false
    }
    
    func performLogout() {
        self.userName = nil
        self.accessToken = nil
    }
    
    func performLogin(contextProvider: ASWebAuthenticationPresentationContextProviding) {
        if let loginUrl = self.getUrlWithComponents(ForHost: "github.com", path: "/login/oauth/authorize", queryItems: [URLQueryItem(name: "client_id", value: self.clientID)]) {
            let authSession = ASWebAuthenticationSession.init(url: loginUrl, callbackURLScheme: self.callbackURLScheme) { (callbackUrl, error) in
                guard error == nil, let tokenUrl = callbackUrl, let queryItems = URLComponents.init(string: tokenUrl.absoluteString)?.queryItems , let code = queryItems.first(where: { $0.name == "code" })?.value else { return }
                if let url = self.getUrlWithComponents(ForHost: "github.com", path: "/login/oauth/access_token", queryItems: [
                    URLQueryItem(name: "client_id", value: "Iv1.c6a2aab38b6147f3"),
                    URLQueryItem(name: "client_secret", value: "de6dffa20ac858c9d034154a943b7bee9bf1cdcd"),
                    URLQueryItem(name: "code", value: code)
                ]) {
                    var request = URLRequest.init(url: url)
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        guard data != nil, error == nil else { return }
                        if var params = String.init(data: data!, encoding: .utf8) {
                            let paramComponents = params.components(separatedBy: "&")
                            for param in paramComponents {
                                let val = param.components(separatedBy: "=")
                                if val[0] == "access_token" {
                                    self.accessToken = val[1]
                                    self.getUserDetails()
                                }
                            }
                        }
                    }
                    task.resume()
                }
            }
            authSession.presentationContextProvider = contextProvider
            authSession.prefersEphemeralWebBrowserSession = true
            if !authSession.start() {
                fatalError()
            }
        }
    }
    
    func getUserDetails() {
        if let url = self.getUrlWithComponents(path: "/user", queryItems: nil) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil, data != nil else { return }
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    self.userName = dict["login"] as! String
                }
            }
            task.resume()
        }
    }
    
    private func getUrlWithComponents(ForHost host: String = "api.github.com", path: String, queryItems: [URLQueryItem]?) -> URL? {
        var urlComponents = URLComponents.init()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}
