//
//  ChatController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 2/23/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit
import os.log
import Foundation


class ChatController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var User: UILabel!
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var chatContainer: UITableView!
    @IBOutlet weak var messageInput: UITextField!
    @IBOutlet weak var usersButton: UIBarButtonItem!
    
    
    var selected = "" // Which user is been selected
    var users = [String:Any]() // dictionary key: usernameand and val: id
    var userLookup = [Int: String]() // dictionary key: id and val: username
    var convID = Int() // Conversation Data - ID
    var convUsers = Int() // Conversation Data - UserID
    var messages = [[String]]() // contains messages
    
    let ws = WebSocket("ws://neurores.ucsd.edu:3000")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(UserDefaults.standard.string(forKey: "user_auth_token") == nil){
            performSegue(withIdentifier: "noLoginTokenSegue", sender: nil)
            return
        }
        
        
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
        
        createLookUpTable()
        
        if(UserDefaults.standard.array(forKey: "conversationMembers") != nil){
            let user_ids = UserDefaults.standard.array(forKey: "conversationMembers")!
            if(users.isEmpty){
                SlideMenuController.getUsers(token: getToken(), myName: getName()) { (users_ret: [[String]], userIDs_ret: NSMutableDictionary, staff_ret: [String:[String]]) in
                   // users = userIDs_ret as Dictionary<String,Any>
                    for (key, item) in userIDs_ret{
                        self.users[key as! String] = item
                    }
                    self.createLookUpTable()
                    self.startConversation(url: "http://neurores.ucsd.edu:3000/start_conversation", info: user_ids as! [Int])
                }
            }else{
                startConversation(url: "http://neurores.ucsd.edu:3000/start_conversation", info: user_ids as! [Int])
            }
        }
        
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

        let testMessage: [String : Any] = ["text": messageInput.text ?? "", "conv_id" : self.convID]
        let testMessageString = self.asString(jsonDictionary: testMessage)
        self.ws.send(testMessageString)
        
        messageInput.text = ""
        scrollToBottom()

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
    
    func getToken() -> String{
        return UserDefaults.standard.string(forKey: "user_auth_token")!
    }
    
    func getName() -> String{
        return UserDefaults.standard.string(forKey: "username")!
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
        request.addValue(getToken(), forHTTPHeaderField: "auth")
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
            self.chatTable.reloadData()
            self.scrollToBottom()
        }
        
        
    }
    
    func asString(jsonDictionary: [String : Any]) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        } catch {
            return ""
        }
    }
    
    /**
     * Function get and start conversation
     * Parameters: url:String - address of endpoint for API call
     *             info: String - json array of userids
     */
    func startConversation(url: String, info: [Int]) {
        var string = ""
        do{
            let data = try JSONSerialization.data(withJSONObject: info)
            string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        }catch{
            print("error serializing info")
        }
        
        let tokenGroup = DispatchGroup()
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue(getToken(), forHTTPHeaderField: "auth")
        request.httpBody = string.data(using: String.Encoding.utf8)
        
        tokenGroup.enter()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                if(httpStatus.statusCode == 401){//unauthorized, send back to Login
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "noLoginTokenSegue", sender: nil)
                    }
                    tokenGroup.leave()
                    return
                }
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                tokenGroup.leave()
                return;
            }
            
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
            self.getMessages(url: "http://neurores.ucsd.edu:3000/get_messages", info: String(self.convID))
            
            
            
            
            
            //let testMessage: [String : Any] = ["text": "some gibberish", "conv_id" : self.convID]
            //

            self.connectSocket()
        }
        
        
    }
    
    func connectSocket(){
        
        
        ws.event.open = {
            let dict: [String : Any] = ["greeting": self.getToken()]
            let dictAsString = self.asString(jsonDictionary: dict)
            self.ws.send(dictAsString)
            
            let testMessage: [String : Any] = ["text": "want some gib", "conv_id" : self.convID]
            let testMessageString = self.asString(jsonDictionary: testMessage)
            self.ws.send(testMessageString)

        }
        ws.event.close = { code, reason, clean in
            print("close")
        }
        ws.event.error = { error in
            print("whoa error")
            print("error \(error)")
        }
        ws.event.message = { myString in
            do {
                
                let myNSString = myString as! String
                let myNSData = myNSString.data(using: String.Encoding.utf8)
                let json = try JSONSerialization.jsonObject(with: myNSData!, options: []) as? [String:Any]
                let userIdInt = json?["from"] as? Int
                let mText = json?["text"] as? String
                let userName = self.getUserName(id: userIdInt!)
                let text = [userName, mText]

                self.messages.append(text as! [String])
                
                self.chatContainer.reloadData()
                self.scrollToBottom()
                
            }catch let error as NSError {
                print(error)
            }

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
        if(userLookup[id] == nil){
            return getName()
        }
        return userLookup[id]! as String
    }
    

    
    
    
}

