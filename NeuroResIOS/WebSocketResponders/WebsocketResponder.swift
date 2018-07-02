//
//  WebsocketResponder.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 6/25/18.
//  Copyright © 2018 Charles McKay. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol WebSocketResponder{
    
    var ws : WebSocket { get set }
    
    func assignWebSocket()
    func saveUsers(json: JSON)
    func addOnlineUser(json: JSON)
    func removeOnlineUser(json: JSON)
    func wipeThread(_ thread: Int)
    func updateCache(_ userID: Int, _ text: String, _ date: Date)
    func onMessageReceive(_ convID: Int, _ userID: Int, _ text: String, _ date: Date, _ pushDown: Bool)
    func getMessages(_ convID: String)
 
    func send(_ packet: String)
    
    func sendGreeting()
    func connectSocket()
}


extension WebSocketResponder {
    
    func sendGreeting(){
        let dict: [String : Any] = ["greeting": ChatController.getToken()]
        let dictAsString = ChatController.asString(jsonDictionary: dict)
        self.send(dictAsString)
    }
    
    func connectSocket(){
        self.assignWebSocket();
        print("Beginning of connect socket");
        ws.event.open = self.sendGreeting
        ws.event.close = { code, reason, clean in
            print("socket close on the server side")
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
                self.wipeThread(json["convID"].int!)
            }else{
                let convID = json["conv_id"].int
                let userIdInt = json["from"].int
                //let userIdString = json["from"}.]
                let mText = json["text"].string!
            
                let date = Date()
            
                self.updateCache(userIdInt!, mText, date)
                self.onMessageReceive(convID!, userIdInt!, mText, date, true)
            
            }
        }
    }
    
    func saveUsers(json : JSON){
        let array = json["activeUsers"].arrayValue.map({$0.stringValue})
        let defaults = UserDefaults.standard
        defaults.set(array, forKey: "onlineUsers")
    }
}
