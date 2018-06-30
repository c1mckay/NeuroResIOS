//
//  NeuroWebView.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 1/24/18.
//  Copyright © 2018 Charles McKay. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import Firebase

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
        
        print(AppDelegate.BASE_URL + "token/tokenGenerator.php")
        //let myURL = URL(string: "https://a5.ucsd.edu/tritON/profile/SAML2/Redirect/SSO?execution=e1s1")
        let myURL = URL(string: AppDelegate.BASE_URL + "token/tokenGenerator.php")
        //let myURL = URL(string: "https://www.google.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("did receive server redirect")
        var x = 4
        x = x + 3
        print(x)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("did commit")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(webView.url == nil || webView.url?.absoluteString == nil){
            return
        }
        var url = webView.url?.absoluteString
        if(url!.contains(AppDelegate.BASE_URL + "key/")){
            url = url?.replacingOccurrences(of: AppDelegate.BASE_URL + "key/", with: "")
            getUserName(url!)
        }else if(url!.contains(AppDelegate.BASE_URL + "token/unathorized")){
            dismiss(animated: true, completion: nil)
        }
    }
    
    func getUserName(_ token: String){
        var erroredOut = false
        let userGroup = DispatchGroup()
        var request = URLRequest(url: URL(string: AppDelegate.BASE_URL + "get_user_name")!)
        request.httpMethod = "post"
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
                print("statusCode should be 200, but is \(httpStatus.statusCode) in getting user name")
                print("response = \(String(describing: response))")
                erroredOut = true
                userGroup.leave()
                return
            }
            var somedata = String(data: data, encoding: String.Encoding.utf8)!
            somedata = somedata.replacingOccurrences(of: "\"", with: "")
            UserDefaults.standard.set(token, forKey: "user_auth_token")
            UserDefaults.standard.set(somedata, forKey: "username")
            
            userGroup.leave()
        }
        task.resume()
        userGroup.wait()
        DispatchQueue.main.async {
            if(erroredOut){
                UserDefaults.standard.removeObject(forKey: "user_auth_token")
                self.dismiss(animated: true, completion: nil)
            }else{
                self.registerNotifToken()
            }
        }
    }
    
    func registerNotifToken(){
        let userGroup = DispatchGroup()
        var request = URLRequest(url: URL(string: AppDelegate.BASE_URL + "firebase_notif")!)
        request.httpMethod = "post"
        request.addValue(SlideMenuController.getToken(), forHTTPHeaderField: "auth")
        print(Messaging.messaging().fcmToken!)
        request.httpBody = String(describing: Messaging.messaging().fcmToken!).data(using: String.Encoding.utf8)
        userGroup.enter()
        
        let task = URLSession.shared.dataTask(with:request){ data, response, error in
            guard let _ = data, error == nil else {
                print("error=\(String(describing: error))")
                userGroup.leave()
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode) in submitting registration token")
                print("response = \(String(describing: response))")
                userGroup.leave()
                return
            }
            
            userGroup.leave()
        }
        task.resume()
        userGroup.wait()
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
