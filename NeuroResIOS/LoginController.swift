//
//  FirstViewController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 2/23/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
// 
//  ViewController for Login Page

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var email: UITextField!

    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var ErrorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
