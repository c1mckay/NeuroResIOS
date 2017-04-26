//
//  FirstViewController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 2/23/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
// 
//  ViewController for Login Page

import UIKit

class LoginController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email: UITextField!

    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var ErrorMessage: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)


        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepare(for segue: UIStoryboardSegue,sender: Any?) {
        //the functionality in this message has now been changed to use UserDefaults
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    
    // Move views when keyboard is present
    func keyboardWillShow(notification: NSNotification) {
        let offset = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                if keyboardSize.height == offset.height {
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        self.view.frame.origin.y -= keyboardSize.height
                    })
                } else {
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        self.view.frame.origin.y += keyboardSize.height - offset.height
                    })
                }
            }
        }
        
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    

    @IBAction func login(_ sender: Any) {
    }

    // TODO: Change email/password verification
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if(!(email.text ?? "").isEmpty){
            get_login("http://neurores.ucsd.edu:3000/login")
        }
        return false
    }
    
    
    /**
     * Function to get user auth token
     * Parameters: url:String - address of endpoint for API call
     */
    func get_login(_ url: String) {
        let tokenGroup = DispatchGroup()
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        //request.addValue(email.text!, forHTTPHeaderField: "auth")
        request.addValue(email.text!, forHTTPHeaderField: "auth") // change later
        tokenGroup.enter()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                DispatchQueue.main.async {
                    self.ErrorMessage.text = "Invalid credentials"
                    self.ErrorMessage.textColor = UIColor.red
                }
            }else{
                DispatchQueue.main.async {
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    UserDefaults.standard.set(responseString, forKey: "user_auth_token")
                    self.ErrorMessage.text = "Success!"
                    self.ErrorMessage.textColor = UIColor.blue
                    self.performSegue(withIdentifier: "successfulLogin", sender: nil)
                }
            }
            tokenGroup.leave()
            
        }
        task.resume()
        tokenGroup.wait()
        DispatchQueue.main.async {
        }
    }
    
    
    
    
}
