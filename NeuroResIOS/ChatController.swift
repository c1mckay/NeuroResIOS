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
    
    var email = "syeu"
    var password = ""
    
    let defaults = UserDefaults.standard
    var token = "" // User's auth token
    var selected = "" // Which user is been selected
    var users = [String:Any]() // dictionary key: usernameand and val: id
    var userLookup = [Int: String]() // dictionary key: id and val: username
    var convID = Int() // Conversation Data - ID
    var convUsers = Int() // Conversation Data - UserID
    var messages = [[String]]() // contains messages
    

    @IBOutlet weak var chatContainer: UITableView!
    
    @IBOutlet weak var messageInput: UITextField!
   
    // Not used any more
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
        
        //get_login("http://neurores.ucsd.edu:3000/login")
        token = defaults.string(forKey: "token")!
        
        chatContainer.estimatedRowHeight = 68.0
        chatContainer.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if self.revealViewController() != nil {
            usersButton.target = self.revealViewController()
            usersButton.action = #selector(SWRevealViewController.revealToggle(_:))
            //self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.revealViewController().rearViewRevealWidth = 290
        
        
        // For displaying keyborad correctly
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        // For dismissing keyboard by tapping
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        // Get list of users and get id of selected user
        users = defaults.dictionary(forKey: "users")!
        selected = defaults.string(forKey: "selected")!
        
        // Get conversation data
        let sid = getIDs(name: selected)
        let ids = "[" + String(sid) + "," + String(getIDs(name: email)) + "]"
        startConversation(url: "http://neurores.ucsd.edu:3000/start_conversation", info: ids)
        
        // Get messagees from conversation
        let cid = String(convID)
        createLookUpTable()
        getMessages(url: "http://neurores.ucsd.edu:3000/get_messages", info: cid)
        
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
        return messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableCell", for: indexPath) as! ChatTableCell
        
        let row = indexPath.row
        
        let username = messages[row][0]
        let text = messages[row][1]
        cell.username.text = username
        //cell.date.text = "date"
        cell.content.text = text
        
        
        return cell
    }
    
    
    // Used to go to the bottom of tableview
    func scrollToBottom(){
        let indexPath = IndexPath(row: self.messages.count-1, section: 0)
        self.chatContainer.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    //TODO: Replace staticmessages and "User". Add code to send message to server later
    @IBAction func sendMessage(_ sender: Any) {
        messages.append(["User",messageInput.text!])
        chatContainer.beginUpdates()
        chatContainer.insertRows(at: [IndexPath(row: messages.count-1, section: 0)], with: .automatic)
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
    
    
  
    
    /**
     * Function to get messages
     * Parameters: url:String - address of endpoint for API call
     *             info: String - Conversation ID
     */
    func getMessages(url: String, info: String) {
        let tokenGroup = DispatchGroup()
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue(self.token, forHTTPHeaderField: "auth")
        request.httpBody = info.data(using: String.Encoding.utf8)

        tokenGroup.enter()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            do {
                
                let parsedData = try JSONSerialization.jsonObject(with: data) as? [[String:Any]]
                
                if !(parsedData?.isEmpty)! {
                    for i in 0 ... ((parsedData?.count))! - 1 {
                        
                        let json = parsedData![i] as? [String:Any]
                        let userid = json!["sender"] as? String
                        let text = json!["text"] as? String
                        let userIdInt = Int(userid!)
                        let userName = self.getUserName(id: userIdInt!)
                        let message = [userName, text]
                        self.messages.append(message as! [String])
                        
                    }
                }
                

            } catch let error as NSError {
                print(error)
            }

            tokenGroup.leave()
            
        }
        task.resume()
        tokenGroup.wait()
        DispatchQueue.main.async {
        }
        
        
    }
    
    
    /**
     * Function get and start conversation
     * Parameters: url:String - address of endpoint for API call
     *             info: String - json array of userids
     */
    func startConversation(url: String, info: String) {
        let tokenGroup = DispatchGroup()
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue(self.token, forHTTPHeaderField: "auth")
        request.httpBody = info.data(using: String.Encoding.utf8)
        
        tokenGroup.enter()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            //let responseString = String(data: data, encoding: .utf8) ?? ""
            //print(responseString)
            do {
                
                let parsedData = try JSONSerialization.jsonObject(with: data) as? [String:Any]
                let key = Array(parsedData!.keys)
                let conv = key[0] as? String
                let val = parsedData?[conv!] as? Int
                self.convID = val!

            } catch let error as NSError {
                print(error)
            };
            tokenGroup.leave()
            
        }
        task.resume()
        tokenGroup.wait()
        DispatchQueue.main.async {
        }
        
        
    }
    
    
    
    /**
     * Function to get UserIDs
     * Parameters: name:String - username
     * Returns:  Int - the user's id
     */
    func getIDs(name:String) -> Int{
        let id = users[selected]
        return id as! Int
    
    }

    /**
     * Function to create a dictionary to get usernames from ids
     */
    func createLookUpTable() {
        for (key, value) in users {
            let id = value as? Int
            userLookup[id!] = key
        
        }
        
    }
    
    func getUserName(id:Int) -> String {
        return userLookup[id]! as String
    }
    

    
    
    
}

