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
//    var refreshToken : String? = UserDefaults.standard.string(forKey: "refresh_token") ?? nil {
//        didSet {
//            UserDefaults.standard.setValue(self.refreshToken, forKey: "refresh_token")
//        }
//    }
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
    
    func performLogin(contextProvider: ASWebAuthenticationPresentationContextProviding, callback: @escaping (Bool) -> ()) {
        if let loginUrl = self.getUrlWithComponents(ForHost: "github.com", path: "/login/oauth/authorize", queryItems: [URLQueryItem(name: "client_id", value: self.clientID)]) {
            let authSession = ASWebAuthenticationSession.init(url: loginUrl, callbackURLScheme: self.callbackURLScheme) { (callbackUrl, error) in
                guard error == nil, let tokenUrl = callbackUrl, let queryItems = URLComponents.init(string: tokenUrl.absoluteString)?.queryItems , let code = queryItems.first(where: { $0.name == "code" })?.value else {
                    callback(false)
                    return
                }
                if let url = self.getUrlWithComponents(ForHost: "github.com", path: "/login/oauth/access_token", queryItems: [
                    URLQueryItem(name: "client_id", value: "Iv1.c6a2aab38b6147f3"),
                    URLQueryItem(name: "client_secret", value: "de6dffa20ac858c9d034154a943b7bee9bf1cdcd"),
                    URLQueryItem(name: "code", value: code)
                ]) {
                    var request = URLRequest.init(url: url)
                    request.httpMethod = "POST"
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        guard data != nil, error == nil else { return }
                        if var params = String.init(data: data!, encoding: .utf8) {
                            let paramComponents = params.components(separatedBy: "&")
                            for param in paramComponents {
                                let val = param.components(separatedBy: "=")
                                if val[0] == "access_token" {
                                    self.accessToken = val[1]
                                    self.getUserDetails { (isSuccesful) in
                                        callback(true)
                                    }
                                }
                            }
                        }
                        callback(false)
                    }
                    task.resume()
                }
                callback(false)
            }
            authSession.presentationContextProvider = contextProvider
            authSession.prefersEphemeralWebBrowserSession = true
            if !authSession.start() {
                fatalError()
            }
        }
    }
    
    func getUserDetails(callback: @escaping (Bool) -> ()) {
        if let url = self.getUrlWithComponents(path: "/user", queryItems: nil) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil, data != nil else {
                    callback(false)
                    return
                }
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    self.userName = dict["login"] as! String
                    callback(true)
                }
                callback(false)
            }
            task.resume()
        }
    }
    
    func getUserRepos(callback: @escaping ([Repository]) -> ()) {
        if let url = self.getUrlWithComponents(path: "/users/\(self.userName!)/repos", queryItems: nil) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil, data != nil else { return }
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                    var repos = [Repository]()
                    for item in dict {
                        repos.append(Repository.init(id: "\(item["id"]!)", name: item["name"] as! String, description: item["description"] as! String))
                    }
                    callback(repos)
                }
            }
            task.resume()
        }
    }
    
    func getRepoIssues(name: String, callback: @escaping ([Issue]) -> ()) {
        if let url = self.getUrlWithComponents(path: "/repos/\(self.userName!)/\(name)/issues", queryItems: nil) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil, data != nil else { return }
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                    var issues = [Issue]()
                    for item in dict {
                        let issue = Issue.init(title: item["title"] as! String, description: (item["body"] as? String) ?? "No description provided")
                        issues.append(issue)
                    }
                    callback(issues)
                }
            }
            task.resume()
        }
    }
    
    func getRepoPullRequests(name: String, callback: @escaping (Int)->()) {
        if let url = self.getUrlWithComponents(path: "/repos/\(self.userName!)/\(name)/pulls", queryItems: nil) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil, data != nil else { return }
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                    var count = dict.count
                    callback(count)
                }
            }
            task.resume()
        }
    }
    
    func createRepoIssue(name: String, title: String, description: String, callback: @escaping (Issue)->()) {
        if let url = self.getUrlWithComponents(path: "/repos/\(self.userName!)/\(name)/issues", queryItems: nil) {//[URLQueryItem.init(name: "title", value: title), URLQueryItem.init(name: "body", value: description)]
            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            var paramDict : [String: Any] = ["title": title, "body": description]
            if let paramData = try? JSONSerialization.data(withJSONObject: paramDict, options: []) {
                request.httpBody = paramData
            }
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "accept")
            request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil, data != nil else { return }
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    let issue = Issue.init(title: title, description: description)
                    callback(issue)
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
