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
        ["Ice Cream Cone", "Ice Creamdddddddddddddddddddd\n\n\n dddasadlkfjsld;kfjasd asdlfkjasdf asdlfksja"],
        ["Ice Cream Sundae",  "Ice Cream"],
        ["Apple Pie",  "Pie"],
        ["Cherry Pie",  "Pie"],
        ["Coconut Cream",  "Pie"],
        ["Tiramisu",  "Cake"],
        ["Chocolate Chip Cookie", "Cookie"],
        ["7-Layer Cake", "Cake"],
        ["Boston Cream Doughnut", "Doughnut"],
        ["Cruller", "Doughnut"],
        ["Long John", "Doughnut"],
        ["Blueberry Muffin", "Cake"],
        ["Vanilla Cupcake", "Cake"],
        ["Shake", "Drink"],
        ["Malted", "Drink"],
        ["Root Beer Float", "Drink"]
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        User.text = email
        
        chatContainer.estimatedRowHeight = 68.0
        chatContainer.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view, typically from a nib.
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
            chatContainer.dataSource = self
        }
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
}

