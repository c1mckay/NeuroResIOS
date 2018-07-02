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
    
    var ws : WebSocket { get }
    
    func saveUsers(json: JSON)
    func addOnlineUser(json: JSON)
    func removeOnlineUser(json: JSON)
    func wipeThread(_ thread: Int)
    func updateCache(_ userID: Int, _ text: String, _ date: Date)
    func pushMessage(_ userID: Int, _ text: String, _ date: Date, _ pushDown: Bool)
 
    func send(_ packet: String)
    func sendGreeting()
    
    func connectSocket(_ ws : WebSocket, _ responder : WebSocketResponder){
        ws.close()
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
            responder.saveUsers(json: json);
            }
            if(json["onlineUser"].exists()){
            responder.addOnlineUser(json: json);
            }
            if(json["offlineUser"].exists()){
            responder.removeOnlineUser(json: json);
            }
            }else if(json["wipeThread"].exists()){
            //to test
            responder.wipeThread(json["convID"].int!)
            }else{
            if json["conv_id"].int != self.convID{
            return
            }
            let userIdInt = json["from"].int
            //let userIdString = json["from"}.]
            let mText = json["text"].string!
    
            let date = Date()
    
            responder.updateCache(userIdInt!, mText, date)
            responder.pushMessage(userIdInt!, mText, date, true)
    
            }
        }
    }
}
