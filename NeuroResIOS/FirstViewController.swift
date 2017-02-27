//
//  FirstViewController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 2/23/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
// 
//  ViewController for Login Page

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var email: UITextField! // User's Login email
    @IBOutlet weak var password: UITextField! // User's password
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func Login(_ sender: Any) {
        print(email.text! + " " + password.text!)
    }
    
    override func prepare(for segue: UIStoryboardSegue,sender: Any?) {
        let secondViewController = segue.destination as! SecondViewController
        secondViewController.email = email.text!
        secondViewController.password = password.text!
    
    }


    // TODO: Change email/password verification
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (email.text?.hasSuffix("@ucsd.edu"))! {
            performSegue(withIdentifier: identifier, sender:nil)
            return true
        }
        else {
            return false
        }
    }
}
