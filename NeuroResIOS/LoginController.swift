//
//  FirstViewController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 2/23/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
// 
//  ViewController for Login Page

import UIKit
import Toast_Swift
import WebKit

class LoginController: UIViewController, UITextFieldDelegate{
    
    
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(firstTime){
            self.view.makeToast("This app is not HIPPA compliant!", duration: 6.0, position: .top)
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        print("login controller loading")
        if(UserDefaults.standard.string(forKey: "user_auth_token") == nil){
            
        }
        
    }
    
    var firstTime = true
    override func viewDidAppear(_ animated: Bool) {
        if(!firstTime){
            if(UserDefaults.standard.string(forKey: "user_auth_token") == nil){
                self.view.makeToast("You aren't allowed to use NeuroRes!", duration: 6.0, position: .top)
            }else{
                self.performSegue(withIdentifier: "successfulLogin", sender: nil)
            }
        }
        firstTime = false
    }

    var webView: WKWebView!
    override func loadView(){
        super.loadView()
        
        /**/
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepare(for segue: UIStoryboardSegue,sender: Any?) {
        //the functionality in this message has now been changed to use UserDefaults
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    

    // TODO: Change email/password verification
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("should perform segue")
        return true
    }
    
    /**
     * Function to get user auth token
     * Parameters: url:String - address of endpoint for API call
     */
    func get_login(_ url: String) {
        
        
    }
    
    
    
    
}
