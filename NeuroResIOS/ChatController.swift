//
//  ChatController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 2/23/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit
import os.log

class ChatController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var User: UILabel!
    
    var email = ""
    var password = ""

    @IBOutlet weak var chatContainer: UITableView!
    
    @IBOutlet weak var messageInput: UITextField!
    var  staticMessages:[[String]] = [
        ["J. Alexander", "Hello"],
        ["C. Konersman",  "This is a chat example with an incredibly long message."],
        ["J. Alexander",  "Back to me."],
        ["C. Konersman",  "I will demonstrate overflowing messages with two messages.\nThis is my second message I submitted.\nMore concept."],
        ["J. Alexander",  "Interesting. I can also play with the borders to see how that looks like."],
        ["C. Konersman",  "Thoughts?"],
        ["J. Alexander", "Hello"],
        ["C. Konersman",  "This is a chat example with an incredibly long message."],
        ["J. Alexander",  "Back to me."],
        ["C. Konersman",  "I will demonstrate overflowing messages with two messages.\nThis is my second message I submitted.\nMore concept."],
        ["J. Alexander",  "Interesting. I can also play with the borders to see how that looks like."],
        ["C. Konersman",  "Thoughts?"],
        ["J. Alexander", "Hello"],
        ["C. Konersman",  "This is a chat example with an incredibly long message."],
        ["J. Alexander",  "Back to me."],
        ["C. Konersman",  "I will demonstrate overflowing messages with two messages.\nThis is my second message I submitted.\nMore concept."],
        ["J. Alexander",  "Interesting. I can also play with the borders to see how that looks like."],
        ["C. Konersman",  "Thoughts?"]
    ]
    
    @IBOutlet weak var usersButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //User.text = email
        
        chatContainer.estimatedRowHeight = 68.0
        chatContainer.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if self.revealViewController() != nil {
            usersButton.target = self.revealViewController()
            usersButton.action = #selector(SWRevealViewController.revealToggle(_:))
            //self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        let screenSize: CGRect = UIScreen.main.fixedCoordinateSpace.bounds
        let sliderWidth = (screenSize.width * 0.7) - 100
        
        self.revealViewController().rearViewRevealWidth = 290
        
        print(screenSize.width)
        print(sliderWidth)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    var configured = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !configured{
            chatContainer.delegate = self
            chatContainer.dataSource = self        }
        configured = true
    }
    

    //MARK: UITableViewDelegate and Datasource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staticMessages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableCell", for: indexPath) as! ChatTableCell
        
        let row = indexPath.row
        
        let username = staticMessages[row][0]
        let text = staticMessages[row][1]
        cell.username.text = username
        //cell.date.text = "date"
        cell.content.text = text
        
        
        return cell
    }
    
    
    // Used to go to the bottom of tableview
    func scrollToBottom(){
        let indexPath = IndexPath(row: self.staticMessages.count-1, section: 0)
        self.chatContainer.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    //TODO: Replace staticmessages and "User". Add code to send message to server later
    @IBAction func sendMessage(_ sender: Any) {
        staticMessages.append(["User",messageInput.text!])
        chatContainer.beginUpdates()
        chatContainer.insertRows(at: [IndexPath(row: staticMessages.count-1, section: 0)], with: .automatic)
        chatContainer.endUpdates()
        chatContainer.reloadData()
        scrollToBottom()
        messageInput.text = ""
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
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    
}

