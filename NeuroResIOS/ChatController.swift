//
//  ChatController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 2/23/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import JSQMessagesViewController
import SwiftyJSON
import UIKit
import os.log
import Foundation



class ChatController: JSQMessagesViewController{
    
    static let MAX_CHARACTERS = 375
    
    let BASE_URL = AppDelegate.BASE_URL
    let ERROR_ID = "-2"
    
    static let OUTGOING_COLOR = AppDelegate.UCSD_MEDIUM_GREY
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUserName = message.senderDisplayName!
        return SearchController.attributedString(from: messageUserName, nonBoldRange: NSMakeRange(0, messageUserName.count))
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
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        
        let text = textView.text!
        let newTextLength = text.count - ChatController.MAX_CHARACTERS
        if(newTextLength > 0){
            let offset = 0 - newTextLength
            let index = text.index(text.endIndex, offsetBy: offset)
            textView.text = text.substring(to: index)
        }
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        hideSlideMenu()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        if(messages.count < indexPath.row || indexPath.row < 0){
            return nil
        }
        return messages[indexPath.row]
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!{
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = messages[indexPath.row]
        
        if getName() == message.senderDisplayName {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: ChatController.OUTGOING_COLOR)
        }else if message.senderId == ERROR_ID{
            return bubbleFactory?.incomingMessagesBubbleImage(with: errorColor())
        }else{
            return bubbleFactory?.incomingMessagesBubbleImage(with: incomingColor())
        }
    }
    
    func incomingColor() -> UIColor{
        return UIColor(0, 106, 150)
    }
    
    func errorColor() -> UIColor{
        return UIColor(255, 99, 71)
    }
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text.count == 0 {
            self.finishSendingMessage()
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
    
    @IBOutlet weak var trash: UIBarButtonItem!
    
    static var MENU_MODE = 4
    
    var selected = "" // Which user is been selected
    var users = [String:Int]() // dictionary key: usernameand and val: id
    var userLookup = [Int: String]() // dictionary key: id and val: username
    var convID = Int() // Conversation Data - ID
    var convUsers = Int() // Conversation Data - UserID
    var messages = [JSQMessage]() // contains messages
    
    var ws = WebSocket(AppDelegate.SOCKET_URL)
    
    
    override func viewDidLoad() {
        self.senderId = "0"
        self.senderDisplayName = ""
        super.viewDidLoad()
        
        if(UserDefaults.standard.string(forKey: "user_auth_token") == nil){
            performSegue(withIdentifier: "noLoginTokenSegue", sender: nil)
            return
        }
        
        self.senderDisplayName = getName()
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.automaticallyScrollsToMostRecentMessage = true
        
        UIApplication.shared.registerForRemoteNotifications()
        
        refreshInputUp()
        
        if self.revealViewController() != nil {
            usersButton.target = self
            usersButton.action = #selector(ChatController.menuClick(_:))
        }
        
        trash.target = self
        trash.action = #selector(ChatController.wipeThreadPrompt(_:))
        
        
        
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
        
        let app = UIApplication.shared
        
        //Register for the applicationWillResignActive anywhere in your app.
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: app)
        loadMessagesAndConnect()
        
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(self, selector: #selector(self.applicationWillResignActive), name:Notification.Name("MY_NAME_NOTIFICATION"), object: nil)
        
        
    }
    
    @objc func applicationWillResignActive(notification: NSNotification) {
        loadMessagesAndConnect()
    }
    
    func loadMessagesAndConnect(){
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
                    self.navigationItem.title = self.userLookup[user_ids[0]]
                    
                    self.startConversation(info: user_ids)
                }
            }else{
                startConversation(info: user_ids)
            }
        }else{
            showNoConversationError()
        }
    }
    
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
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
        conversationError("Looks like you haven't started any conversations yet. Open up the menu on the left to start one.")    }
    
    func conversationError(_ textToDisplay: String){
        self.inputToolbar.isHidden = true
        
        let newMessage = JSQMessage(senderId: ERROR_ID, displayName: "NeuroRes", text: textToDisplay)
        for index in 0 ..< messages.count{
            let x = messages[index]
            if x.senderId == ERROR_ID {
                messages[index] = newMessage!
                self.finishSendingMessage()
                return
            }
        }
        
        self.messages.append(newMessage!)
        self.finishSendingMessage()
    }
    
    @objc func onConversationPaneClick(_ sender: Any){
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

    @objc func wipeThreadPrompt(_ sender: Any){
        let refreshAlert = UIAlertController(title: "Wipe Messages", message: "All messages will be deleted.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.wipeThread()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func wipeThread(){
        self.messages = []
        
        let tokenGroup = DispatchGroup()
        var request = URLRequest(url: URL(string: BASE_URL + "wipe_conversation")!)
        request.httpMethod = "POST"
        request.addValue(getToken(), forHTTPHeaderField: "auth")
        request.httpBody = String(describing: self.convID).data(using: String.Encoding.utf8)
        
        tokenGroup.enter()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            guard let _ = data, error == nil else {
                print("error=\(String(describing: error))")
                tokenGroup.leave()
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
            
            tokenGroup.leave()
            
        }
        task.resume()
        tokenGroup.wait()
        DispatchQueue.main.async {
            self.getMessages(String(self.convID))
        }
    }
    
    @objc func menuClick(_ sender : Any){
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
     * Function to get messages (loadMessage)
     * Parameters: url:String - address of endpoint for API call
     *             info: String - Conversation ID
     */
    func getMessages(_ convID: String) {
        let tokenGroup = DispatchGroup()
        var request = URLRequest(url: URL(string: BASE_URL + "get_messages")!)
        request.httpMethod = "POST"
        request.addValue(getToken(), forHTTPHeaderField: "auth")
        request.httpBody = convID.data(using: String.Encoding.utf8)

        tokenGroup.enter()
        var array = [(Int, String, Date)]()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                tokenGroup.leave()
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                tokenGroup.leave()
                return;
            }
            
            self.messages.removeAll()
            let parsedData = ChatController.dataToJSON(data)
            ChatController.CacheConvo(convID, parsedData.rawString()!)
            
            array = self.parseJSONToConvData(parsedData)
            
            
            

            tokenGroup.leave()
            
        }
        task.resume()
        tokenGroup.wait()
        DispatchQueue.main.async {
            let hadMessage = !self.messages.isEmpty
            if array.count == 0{
                array = self.loadConvDataCache(convID)
            }
            
            
            for (userID, text, date) in array{
                self.pushMessage(userID, text, date)
            }
            
            if hadMessage{
                let pop = self.messages.remove(at: 0)
                self.messages.append(pop)
            }
            self.finishSendingMessage()
            //self.chatContainer.reloadData()
            //self.scrollToBottom()
        }
    }
    
    static func convertFromJSONDate(_ date_s: String ) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateFormatter.date(from : date_s)!
    }
    
    static func CacheConvo(_ convID_s: String, _ stringEncoding: String){
        UserDefaults.standard.set(stringEncoding, forKey: AppDelegate.CACHE_CONV + convID_s)
    }
    
    func loadJSONConvoData(_ convID: String) -> JSON{
        let userCacheStringVal = UserDefaults.standard.value(forKey: AppDelegate.CACHE_CONV + convID)
        if userCacheStringVal == nil{
            return JSON.init("[]")
        }else{
            return JSON.init(parseJSON: userCacheStringVal as! String)
        }
    }
    
    func loadConvDataCache(_ convID: String) -> [(Int, String, Date)]{
        let parsedJson = loadJSONConvoData(convID)
        
        return parseJSONToConvData(parsedJson)
    }
    
    func parseJSONToConvData(_ parsedData: JSON) -> [(Int, String, Date)]{
        var array = [(Int, String, Date)]()
        
        for json in parsedData.array! {
            let userid = json["sender"].string
            let text = json["text"].string
            let userIdInt = Int(userid!)!
            let date_s = json["date"].string
            
            let dateShow = ChatController.convertFromJSONDate(date_s!)
            array.append((userIdInt, text!, dateShow))
        }
        
        return array
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
        self.messages.append(jqMessage!)
        
    }
    
    /**
     * Function get and start conversation
     * Parameters: url:String - address of endpoint for API call
     *             info: String - json array of userids
     */
    func startConversation(info: [Int]) {
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
        var request = URLRequest(url: URL(string: BASE_URL + "start_conversation")!)
        request.httpMethod = "POST"
        request.addValue(getToken(), forHTTPHeaderField: "auth")
        request.httpBody = string.data(using: String.Encoding.utf8)
        
        tokenGroup.enter()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                tokenGroup.leave()
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                if(httpStatus.statusCode == 401 || httpStatus.statusCode == 403){//unauthorized, send back to Login
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
            self.saveConvIDCache(info, self.convID)

            tokenGroup.leave()
            
        }
        task.resume()
        tokenGroup.wait()
        DispatchQueue.main.async {
            if self.convID == 0 {
                let foundID = self.loadConvIDCache(info)
                if foundID != 0{
                    self.getMessages(String(foundID))
                }
                self.conversationError("You are not connected to NeuroRes, and therefore unable to send messages.")
                return
            }
            self.getMessages(String(self.convID))
            self.setUnread()
            self.connectSocket()
        }
    }
    
    func saveConvIDCache(_ usersInput: [Int], _ convID: Int){
        let encoding = getEncoding(usersInput)
        UserDefaults.standard.set(convID, forKey: encoding)
    }
    
    func getEncoding(_ usersInput: [Int]) -> String{
        var encoding = ""
        let users = usersInput.sorted()
        for x in users{
            encoding += (String(describing: x) + ",")
        }
        return AppDelegate.CACHE_CONV_PHONEBOOK + encoding
    }
    
    func loadConvIDCache(_ users: [Int]) -> Int{
        let userEncoding = getEncoding(users)
        
        let convID = UserDefaults.standard.value(forKey: userEncoding)
        if convID == nil{
            return 0
        }
        
        return (convID as! Int?)!
    }
    
    func setUnread(){
        var request = URLRequest(url: URL(string: BASE_URL + "mark_seen")!)
        request.httpMethod = "POST"
        request.addValue(getToken(), forHTTPHeaderField: "auth")
        request.httpBody = String(describing: self.convID).data(using: String.Encoding.utf8)
        
        let tokenGroup = DispatchGroup()
        tokenGroup.enter()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                tokenGroup.leave()
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
            
            tokenGroup.leave()
            
        }
        task.resume()
        tokenGroup.wait()
        DispatchQueue.main.async {}
    }
    
    static func dataToJSON(_ data: Data) -> JSON{
        let somedata = String(data: data, encoding: String.Encoding.utf8)!
        return JSON.init(parseJSON: somedata)
    }
    
    func sendGreeting(){
        let dict: [String : Any] = ["greeting": self.getToken()]
        let dictAsString = self.asString(jsonDictionary: dict)
        self.ws.send(dictAsString)
    }
    
    func connectSocket(){
        ws.close()
        ws = WebSocket(AppDelegate.SOCKET_URL)
        ws.event.open = sendGreeting
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
            }else if(json["wipeThread"].exists()){
                //to test
                self.messages = []
                ChatController.CacheConvo(String(json["convID"].int!), "[]")
            }else{
                if json["conv_id"].int != self.convID{
                    return
                }
                let userIdInt = json["from"].int
                //let userIdString = json["from"}.]
                let mText = json["text"].string
                
                let date = Date()

                self.updateCache(userIdInt!, mText!, date)
                
                self.pushMessage(userIdInt!, mText!, date)
                self.collectionView.reloadData()
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    func updateCache(_ userIdInt : Int, _ text : String, _ date: Date){
        
        var jo = JSON.init(parseJSON: "{}")
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
        jo["sender"].string = String(describing: userIdInt)
        jo["text"].string = text
        jo["date"].string = df.string(from: date)
        
        
        
        var convCache = self.loadJSONConvoData(String(describing: self.convID))
        convCache.appendIfArray(json: jo)
        
        ChatController.CacheConvo(String(describing: self.convID), convCache.rawString()!)
        
        
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
    

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Forward the token to your provider, using a custom method.
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
        //self.disableRemoteNotificationFeatures()
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

extension JSON{
    mutating func appendIfArray(json:JSON){
        if var arr = self.array{
            arr.append(json)
            self = JSON(arr);
        }
    }
    
    mutating func appendIfDictionary(key:String,json:JSON){
        if var dict = self.dictionary{
            dict[key] = json;
            self = JSON(dict);
        }
    }
}

