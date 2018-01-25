//
//  NeuroWebView.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 1/24/18.
//  Copyright © 2018 Charles McKay. All rights reserved.
//

import UIKit
import WebKit

class NeuroWebController: UIViewController, WKNavigationDelegate{
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: "https://neurores.ucsd.edu/token/tokenGenerator.php")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(webView.url == nil || webView.url?.absoluteString == nil){
            return
        }
        var url = webView.url?.absoluteString
        if(url!.contains("https://neurores.ucsd.edu/key/")){
            url = url?.replacingOccurrences(of: "https://neurores.ucsd.edu/key/", with: "")
            print(url)
            getUserName(url!)
        }else if(url!.contains("https://neurores.ucsd.edu/token/unathorized")){
            dismiss(animated: true, completion: nil)
        }
    }
    
    func getUserName(_ token: String){
        var erroredOut = false
        let userGroup = DispatchGroup()
        var request = URLRequest(url: URL(string: AppDelegate.BASE_URL + "get_user_name")!)
        request.httpMethod = "POST"
        request.addValue(token, forHTTPHeaderField: "auth")
        userGroup.enter()
        
        let task = URLSession.shared.dataTask(with:request){ data, response, error in
            guard let data = data, error == nil else {
                erroredOut = true
                print("error=\(String(describing: error))")
                userGroup.leave()
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode) in getting users")
                print("response = \(String(describing: response))")
                erroredOut = true
                userGroup.leave()
                return
            }
            let somedata = String(data: data, encoding: String.Encoding.utf8)!
            UserDefaults.standard.set(token, forKey: "user_auth_token")
            UserDefaults.standard.set(somedata, forKey: "username")
            
            userGroup.leave()
        }
        task.resume()
        userGroup.wait()
        DispatchQueue.main.async {
            if(erroredOut){
                UserDefaults.standard.removeObject(forKey: "user_auth_token")
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
