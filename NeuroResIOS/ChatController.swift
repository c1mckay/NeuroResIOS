//
//  ChatController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 2/23/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import SwiftyJSON
import UIKit
import os.log
import Foundation
import JSQMessagesViewController



class ChatController: JSQMessagesViewController{
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUserName = message.senderDisplayName!
        return SearchController.attributedString(from: messageUserName, nonBoldRange: NSMakeRange(0, messageUserName.characters.count))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if(indexPath.row == 0){
            return 20
        }
        let prevID = messages[indexPath.row - 1].senderId
        let curID  = messages[indexPath.row].senderId
        
        if(prevID == curID){
            return 0
        }else{
            return 20
        }
        
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        print("clicked")
        hideSlideMenu()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!{
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = messages[indexPath.row]
        
        if getName() == message.senderDisplayName {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: outgoingColor())
        }else{
            return bubbleFactory?.incomingMessagesBubbleImage(with: incomingColor())
        }
    }
    
    func incomingColor() -> UIColor{
        return UIColor(0, 106, 150)
    }
    
    func outgoingColor() -> UIColor{
        return UIColor(182, 177, 169)
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("clicked")
        if text.characters.count == 0 {
            return
        }
        let testMessage: [String : Any] = ["text": text, "conv_id" : self.convID]
        let testMessageString = self.asString(jsonDictionary: testMessage)
        self.ws.send(testMessageString)
        self.finishSendingMessage()
    }
    
    @IBOutlet weak var User: UILabel!
    @IBOutlet weak var messageInput: UITextField!
    @IBOutlet weak var usersButton: UIBarButtonItem!
    
    static var MENU_MODE = 4
    
    var selected = "" // Which user is been selected
    var users = [String:Int]() // dictionary key: usernameand and val: id
    var userLookup = [Int: String]() // dictionary key: id and val: username
    var convID = Int() // Conversation Data - ID
    var convUsers = Int() // Conversation Data - UserID
    var messages = [JSQMessage]() // contains messages
    
    let ws = WebSocket("wss://neurores.ucsd.edu")
    
    
    override func viewDidLoad() {
        self.senderId = "0"
        self.senderDisplayName = ""
        super.viewDidLoad()
        
        if(UserDefaults.standard.string(forKey: "user_auth_token") == nil){
            print("not found")
            performSegue(withIdentifier: "noLoginTokenSegue", sender: nil)
            return
        }
        
        self.senderDisplayName = getName()
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.automaticallyScrollsToMostRecentMessage = true
        
        
        refreshInputUp()
        
        if self.revealViewController() != nil {
            usersButton.target = self//.revealViewController()
            usersButton.action = #selector(ChatController.menuClick(_:))
        }
        
        
        
        self.revealViewController().rearViewRevealWidth = 290
        
        
        // For displaying keyborad correctly
        //NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        // For dismissing keyboard by tapping
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatController.onConversationPaneClick))
        self.view.addGestureRecognizer(tap)
        
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left, .up, .down]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(ChatController.handleSwipe))
            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
        }
        
        //let swiperight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        //swiperight.direction = UISwipeGestureRecognizerDirection.right
        //self.view.addGestureRecognizer(swipeleft)

        
        createLookUpTable()
        
        if(conversationSelected()){
            self.inputToolbar.isHidden = false
            let user_ids = (UserDefaults.standard.array(forKey: "conversationMembers")!).map {$0} as! [Int]
            if(users.isEmpty){
                SlideMenuController.getUsers(token: getToken(), myName: getName()) { (users_ret: [String], userIDs_ret: [String:Int], staff_ret: [String:[String]]) in
                    
                    for (key, item) in userIDs_ret{
                        self.users[key] = item
                    }
                    self.senderDisplayName = self.getName()
                    self.senderId = String(describing: self.users[self.getName()]!)
                    
                    self.createLookUpTable()
                    
                    let leftItem = UIBarButtonItem(title: self.userLookup[user_ids[0]],
                                                   style: UIBarButtonItemStyle.plain,
                                                   target: nil,
                                                   action: nil)
                    leftItem.isEnabled = false
                    self.navigationItem.rightBarButtonItem = leftItem
                    
                    self.startConversation(url: "https://neurores.ucsd.edu/start_conversation", info: user_ids)
                }
            }else{
                startConversation(url: "https://neurores.ucsd.edu/start_conversation", info: user_ids)
            }
        }else{
            showNoConversationError()
        }
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.right:
            if !self.slideMenuShowing() {
                self.revealViewController().revealToggle(self.revealViewController())
            }
        case UISwipeGestureRecognizerDirection.left:
            if self.slideMenuShowing() {
                self.revealViewController().revealToggle(self.revealViewController())
            }
        default:
            break
        }

    }
    
    func showNoConversationError(){
        self.inputToolbar.isHidden = true
        self.messages.append(JSQMessage(senderId: "-1", displayName: "NeuroRes", text: "Looks like you haven't started any conversations yet. Open up the menu on the left to start one."))
        self.finishSendingMessage()
    }
    
    func onConversationPaneClick(_ sender: Any){
        hideSlideMenu()
        refreshInputUp()
        self.dismissKeyboard()
    }
   
    
    func hideSlideMenu(){
        if(slideMenuShowing()){
            let controller = self.revealViewController()
            controller?.revealToggle(controller)
        }
    }

    func menuClick(_ sender : Any){
        self.dismissKeyboard()
        let controller = self.revealViewController()
        controller?.revealToggle(controller)
        refreshInputUp()
    }
    
    func slideMenuShowing() -> Bool {
        return self.revealViewController().frontViewPosition.rawValue == ChatController.MENU_MODE;
    }
    
    func refreshInputUp(){
        
    }
    
    func conversationSelected() -> Bool{
        if(UserDefaults.standard.array(forKey: "conversationMembers") == nil){
            return false
        }
        
        let user_ids = (UserDefaults.standard.array(forKey: "conversationMembers")!).map {$0} as! [Int]
        return !user_ids.isEmpty
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /*var configured = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !configured{
            chatContainer.delegate = self
            chatContainer.dataSource = self        }
        configured = true
    }*/
    

    //MARK: UITableViewDelegate and Datasource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    /*func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableCell", for: indexPath) as! ChatTableCell
        
        let row = indexPath.row
        
        let username = messages[row][0]
        let text = messages[row][1]
        cell.username.text = username
        cell.date.text = messages[row][2]
        cell.content.text = text
        
        return cell
    }*/
    
    
    // Used to go to the bottom of tableview
    func scrollToBottom(){
        if(self.messages.count <= 0){
            return
        }
        
        //let indexPath = IndexPath(row: self.messages.count-1, section: 0)
        //self.chatContainer.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    @IBAction func sendMessage(_ sender: Any) {

        
        
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
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            do {
                
                let parsedData = try JSONSerialization.jsonObject(with: data) as? [[String:Any]]
                print(parsedData)
                if !(parsedData?.isEmpty)! {
                    for i in 0 ... ((parsedData?.count))! - 1 {
                        
                        let json = parsedData![i] as [String:Any]
                        let userid = json["sender"] as? String
                        let text = json["text"] as? String
                        let userIdInt = Int(userid!)!
                        let date_s = json["date"] as! String
                        
                        let dateShow = self.convertFromJSONDate(date_s)
                        self.pushMessage(userIdInt, text!, dateShow)
                        
                        
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
            self.finishSendingMessage()
            //self.chatContainer.reloadData()
            //self.scrollToBottom()
        }
    }
    
    func convertFromJSONDate(_ date_s: String ) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateFormatter.date(from : date_s)!
        
        //return getTimeString(date!)
    }
    
    func getTimeString(_ date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        return dateFormatter.string(from: date)
    }
    
    func asString(jsonDictionary: [String : Any]) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        } catch {
            return ""
        }
    }
    
    func pushMessage(_ userIdInt: Int, _ text: String, _ date: Date){
        let userIdString = String(describing: userIdInt)
        let displayName = self.getUserName(id: userIdInt)

        /*if(!self.messages.isEmpty){
            let lastMessage = messages[self.messages.count - 1]
            if(lastMessage.senderId == userIdString){
                displayName = ""
            }
        }*/
        let jqMessage = JSQMessage(senderId: userIdString, displayName: displayName, text: text)
        self.messages.append(jqMessage!)    }
    
    /**
     * Function get and start conversation
     * Parameters: url:String - address of endpoint for API call
     *             info: String - json array of userids
     */
    func startConversation(url: String, info: [Int]) {
        if(info.isEmpty){
            print("Trying to start a conversation with no one")
            return
        }
        var string = ""
        do{
            let data = try JSONSerialization.data(withJSONObject: info)
            string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
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
                print("error=\(String(describing: error))")
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
                print("response = \(String(describing: response))")
                tokenGroup.leave()
                return;
            }
            
            let parsedData = ChatController.dataToJSON(data)	
            self.convID = parsedData["conv_id"].int!

            tokenGroup.leave()
            
        }
        task.resume()
        tokenGroup.wait()
        DispatchQueue.main.async {
            self.getMessages(url: "https://neurores.ucsd.edu/get_messages", info: String(self.convID))

            self.connectSocket()
        }
    }
    
    static func dataToJSON(_ data: Data) -> JSON{
        let somedata = String(data: data, encoding: String.Encoding.utf8)!
        return JSON.init(parseJSON: somedata)
    }
    
    func connectSocket(){
        
        ws.event.open = {
            let dict: [String : Any] = ["greeting": self.getToken()]
            let dictAsString = self.asString(jsonDictionary: dict)
            self.ws.send(dictAsString)
        }
        ws.event.close = { code, reason, clean in
            print("socket close")
            print(reason)
            print(code)
        }
        ws.event.error = { error in
            print("whoa, error in websocket")
            print("error \(error)")
        }
        ws.event.message = { myString in
            let json = JSON.init(parseJSON : myString as! String)
            if (json["userStatusUpdate"].exists()){
                if(json["activeUsers"].exists()){
                    self.saveUsers(json: json);
                }
                if(json["onlineUser"].exists()){
                    self.addOnlineUser(json: json);
                }
                if(json["offlineUser"].exists()){
                    self.removeOnlineUser(json: json);
                }
            }else{
                print("received")
                let userIdInt = json["from"].int
                let mText = json["text"].string
                
                let date = Date()

                self.pushMessage(userIdInt!, mText!, date)
                self.collectionView.reloadData()
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    func saveUsers(json : JSON){
        let array = json["activeUsers"].arrayValue.map({$0.stringValue})
        let defaults = UserDefaults.standard
        defaults.set(array, forKey: "onlineUsers")
    }
    
    func removeOnlineUser(json : JSON){
        let offline = String(describing: json["offlineUser"].int! as Int)
        var onlineUsers = (UserDefaults.standard.array(forKey: "onlineUsers")!).map { $0 as! String }
        onlineUsers = onlineUsers.filter(){$0 != offline}
        
        let defaults = UserDefaults.standard
        defaults.set(onlineUsers, forKey: "onlineUsers")
    }
    
    func addOnlineUser(json : JSON){
        let offline = String(describing: json["onlineUser"].int! as Int)
        var onlineUsers = (UserDefaults.standard.array(forKey: "onlineUsers")!).map { $0 as! String }
        onlineUsers.append(offline)
        
        let defaults = UserDefaults.standard
        defaults.set(onlineUsers, forKey: "onlineUsers")
    }
    

    /**
     * Function to get UserIDs
     * Parameters: name:String - username
     * Returns:  Int - the user's id
     */
    func getIDs(name:String) -> Int{
        let id = users[selected]
        return id!
    
    }

    /**
     * Function to create a dictionary to get usernames from ids
     */
    func createLookUpTable() {
        for (key, value) in users {
            userLookup[value] = key
        
        }
        
    }
    
    func getUserName(id:Int) -> String {
        if(userLookup[id] == nil){
            return getName()
        }
        return userLookup[id]! as String
    }
    


    
    
    
}

extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

