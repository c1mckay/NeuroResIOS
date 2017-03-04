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
        //let secondViewController = segue.destination as! ChatController
        //secondViewController.email = email.text!
        //secondViewController.password = password.text!
    
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
        //if (email.text?.hasSuffix("@ucsd.edu") || true)! {
            //performSegue(withIdentifier: identifier, sender:nil)
            return true
        /*}
        else {
            ErrorMessage.text = "Incorrect Password"
            ErrorMessage.textColor = UIColor.red
            return false
        }*/
    }
}
