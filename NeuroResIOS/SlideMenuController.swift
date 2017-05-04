//
//  SlideMenuControllerViewController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/1/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit

protocol SlideMenuDelegate{
    func slideMenuItemSelectedAtIndex(_ index: Int32)
}

class SlideMenuController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    /**
    *   Array to display menu options
    */
    @IBOutlet weak var usersList: UITableView!
    
    
    /**
    *   Transparent button to hide menu
    */

    @IBOutlet var btnCloseMenuOverlay: UIButton!

    /**
    *   array containing menu options
    */
    
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
    *   Menu button which was tapped to display the menu
    */
    var btnMenu: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    /**
    *   Delegate of the MenuVC
    */
    var delegate: SlideMenuDelegate?
    
    var unread_showing = true
    var staff_showing = true
    var users_showing = false
    var staff_type_hiding:[String] = []
    
    
    func getToken() -> String{
        return UserDefaults.standard.value(forKey: "user_auth_token")! as! String;
    }
    
    func getName() -> String{
        return UserDefaults.standard.value(forKey: "username")! as! String;
    }
    
    
    /**
     * Function to get list of users
     * Parameters: url:String - address of endpoint for API call
     */
    static func getUsers(token: String, myName: String, completion: @escaping (_ : [[String]], _ : NSMutableDictionary, _ : [String:[String]]) -> Void ) {
            print("getting users")
        
        var users:[[String]] = []
        var usersIDs:NSMutableDictionary = [:]
        var staff:[String:[String]] = [:]
        
        let userGroup = DispatchGroup()
        var request = URLRequest(url: URL(string: "http://neurores.ucsd.edu:3000/users_list")!)
        request.httpMethod = "POST"
        request.addValue(token, forHTTPHeaderField: "auth")
        userGroup.enter()
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
                
                for i in 0 ... ((parsedData?.count))! - 1 {
                
                    let json = parsedData![i] as [String:Any]
                    let name = json["email"] as? String
                    if(name == myName){
                        continue
                    }
                    let id = json["user_id"] as? Int
                    users.append([name!])
                    usersIDs[name!] = id
                    let userType = json["user_type"] as? String
                    if staff[userType!] != nil {
                        staff[userType!]!.append(name!)
                    }
                    else{
                        staff[userType!] = [name!]
                    }
                }
            } catch let error as NSError {
                print(error)
            }
            userGroup.leave()
        }
        task.resume()
        userGroup.wait()
        DispatchQueue.main.async {
            completion(users, usersIDs, staff)
        }
    
    
    }
    
    
    
    var usersIDs:NSMutableDictionary = [:]
    var users:[[String]] = []
    var staff:[String:[String]] = [:]
    var unread:[String] = []
    var staffKeys:[String] = []
    
    @IBOutlet weak var userTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameLabel.text = getName()
        
        // Get users
        SlideMenuController.getUsers(token: getToken(), myName: getName()) { (users_ret: [[String]], userIDs_ret: NSMutableDictionary, staff_ret: [String:[String]]) in
            self.users = users_ret
            self.staff = staff_ret
            self.usersIDs = userIDs_ret
            
            self.staffKeys = Array(self.staff.keys)
            
            
            for staff_type_name in self.staffKeys{
                self.staff_type_hiding.append(staff_type_name)
            }
            
            self.userTableView.reloadData()
        }
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "staffNameSelect" || segue.identifier == "directNameSelect" {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
                self.view.layoutIfNeeded()
                self.view.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            })
        
        }
    }
    

    
    
    @IBAction func onCloseMenuClick(_ button:UIButton!){
        btnMenu.tag = 0
        if (self.delegate != nil) {
            var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        })

    }
    
    var configured = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !configured{
            usersList.delegate = self
            usersList.dataSource = self
        }
        configured = true
    }
    
    //MARK: UITableViewDelegate and Datasource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var unread_section = unread.count
        if(unread.count > 0){
            unread_section += 1
            if(!users_showing){
                unread_section -= unread.count
            }
        }
        var row_count = 0;
        
        row_count += unread_section
        row_count += 1 //for staff 'big' header
        if(staff_showing){
            row_count += staff.count // keys of the staff. i dont add these because the headers are also 'hidden'
            row_count += getStaffCount()
        }
        
        row_count += 1 //for users 'big' header
        if(users_showing){
            row_count += users.count
            row_count += 1 //for the last row of label 'more'
        }
        
        return row_count
    }
    
    func getStaffCount() -> Int{
        var staff_subsection = 0;
        if(staff_showing){
            for(staff_type_name, staff_names) in staff{
                if(!staff_type_hiding.contains(staff_type_name)){
                    staff_subsection += staff_names.count
                }
            }
        }
        
        return staff_subsection
    }
    
    func unreadHeader(indexPath: IndexPath) -> Bool{
        return unread.count > 0 && indexPath.row == 0
    }
    
    func unreadCell(indexPath: IndexPath) -> Bool{
        if(unread.count == 0 || !unread_showing){
            return false
        }
        return indexPath.row - 1 < unread.count
    }
    
    func staffHeader(indexPath: IndexPath) -> Bool{
        let row = indexPath.row
        if(unread.count == 0){
            return row == 0
        }
        return row == unread.count + 1;
    }

    func usersHeader(indexPath: IndexPath) -> Bool{
        var row = indexPath.row
        if(unread.count != 0){
            row -= (unread.count + 1)
        }
        row -= 1 //for the staff 'big' header
        if(staff_showing){
            row -= (staff.count)
        }
        row -= getStaffCount()//will return 0 if staff isn't showing
        return row == 0
    }
    
    func staffTypeCell(indexPath: IndexPath) -> Bool{
        if(!staff_showing){
            return false
        }
        var row = indexPath.row
        if(unread.count != 0){
            row -= (unread.count + 1)
        }
        row -= 1 //for Staff entirety section
        
        if(staff.count > 0){
            for i in 0 ... staff.count - 1{
                if(row == 0){
                    return true;
                }
                row -= 1
                if(!staff_type_hiding.contains(staffKeys[i])){
                    row -= (staff[staffKeys[i]]?.count)!
                }
            }
        }
        return false
    }
    
    func staffNameCell(indexPath: IndexPath) -> Bool{
        if(!staff_showing){
            return false
        }
        var row = indexPath.row
        if(unread.count != 0){
            row -= (unread.count + 1)
        }
        
        row -= 1
        
        var size = 0
        if(staff.count > 0){
            for i in 0 ... (staff.count - 1) {
                row -= 1
                if(staff_type_hiding.contains(staffKeys[i])){
                    size = 0
                }else{
                    size = (staff[staffKeys[i]]?.count)!
                }
            
                if(row >= 0 && row < size){
                    return true
                }
            
                if(!staff_type_hiding.contains(staffKeys[i])){
                    row -= size
                }
            }
        }
        return false
    }
    
    
    
    func header(indexPath: IndexPath) -> Bool{
        return unreadHeader(indexPath: indexPath) || staffHeader(indexPath: indexPath) || usersHeader(indexPath: indexPath)
    }
    
    //the ... show more people button
    func moreCell(indexPath: IndexPath) -> Bool{
        if(!users_showing){
            return false
        }
        var unread_section = unread.count
        if(unread.count > 0){
            unread_section += 1
        }
        
        var total_count = 0
        
        total_count += unread_section
        total_count += 1 //for staff big header
        if(staff_showing){
            total_count += staff.count
            total_count += getStaffCount()
        }
        
        total_count += 1 //for users big header
        if(users_showing){
            total_count += users.count
        }
        
        return total_count == indexPath.row
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(header(indexPath: indexPath)){
            return 40
        }else{
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(unreadHeader(indexPath: indexPath)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatHeaderCell", for: indexPath) as! ChatHeaderCell
            
            cell.titleText.text = "Not Read"
            cell.expander.image = getExpanderImage(status: unread_showing)
            
            return cell
        }else if(unreadCell(indexPath: indexPath)){ //for title text
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDescripCell", for: indexPath) as! ChatDescripCell
            
            cell.name.text = unread[indexPath.row - 1]
            
            return cell
        }else if(staffHeader(indexPath: indexPath)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatHeaderCell", for: indexPath) as! ChatHeaderCell
            
            cell.titleText.text = "Staff"
            cell.expander.image = getExpanderImage(status: staff_showing)
            
            return cell
        
        }else if(staffTypeCell(indexPath: indexPath)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaffDescripCell", for: indexPath) as! StaffDescripCell
            
            var staffCell = indexPath.row
            if(unread.count > 0){
                staffCell -= unread.count + 1
            }
            staffCell -= 1 //staff header
            
            for i in 0 ... staff.count - 1{
                if(staffCell == 0){
                    cell.name.text = staffKeys[i]
                    cell.expander.image = getExpanderImage(status: !staff_type_hiding.contains(staffKeys[i]))
                    return cell
                }
                staffCell -= 1//
                if(!staff_type_hiding.contains(staffKeys[i])){//showing
                    staffCell -= (staff[staffKeys[i]]?.count)!
                }
            }
            
            return cell
        }else if(staffNameCell(indexPath: indexPath)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaffNameDescripCell", for: indexPath) as! StaffNameDescripCell
            cell.name.text = getStaffTextName(indexPath: indexPath)
            
            
            return cell
        }else if(usersHeader(indexPath: indexPath)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatHeaderCell", for: indexPath) as! ChatHeaderCell
            
            cell.titleText.text = "Private"
            cell.expander.image = getExpanderImage(status: users_showing)
            
            return cell
        }else if(moreCell(indexPath: indexPath)){
            return tableView.dequeueReusableCell(withIdentifier: "MoreDescripCell", for: indexPath) as! MoreDescripCell        
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDescripCell", for: indexPath) as! ChatDescripCell
        
            cell.name.text = getDirectUserName(indexPath: indexPath)
            cell.unreadCount.isHidden = true
        
            return cell
        }
    }
    
    func getExpanderImage(status: Bool) -> UIImage{
        var imageName:String = "contract"
        if(status){
            imageName = "expand"
        }
        return UIImage(named: imageName)!
        //return UIImageView(image: image!)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(unreadHeader(indexPath: indexPath)){
            unread_showing = !unread_showing
        }else if(staffHeader(indexPath: indexPath)){
            staff_showing = !staff_showing
            print(staff)
        }else if(staffTypeCell(indexPath: indexPath)){
            var staffCell = indexPath.row
            if(unread.count > 0){
                staffCell -= unread.count + 1
            }
            staffCell -= 1 //staff header
            
            for i in 0 ... staff.count - 1{
                let type_name = staffKeys[i]
                if(staffCell == 0){
                    if(staff_type_hiding.contains(type_name)){
                        let index = staff_type_hiding.index(of: type_name)
                        staff_type_hiding.remove(at: index!)
                    }else{
                        staff_type_hiding.append(type_name)
                    }
                    break
                }
                staffCell -= 1
                if(!staff_type_hiding.contains(type_name)){
                    staffCell -= (staff[staffKeys[i]]?.count)!
                }
            }
        }else if(usersHeader(indexPath: indexPath)){
            users_showing = !users_showing
        }else if(staffNameCell(indexPath: indexPath)){
            setConversationMembers(name: getStaffTextName(indexPath: indexPath))
            print("clicking on staff name")
        }else if(!moreCell(indexPath: indexPath) && !unreadCell(indexPath: indexPath)){
            setConversationMembers(name: getDirectUserName(indexPath: indexPath))
            print(getDirectUserName(indexPath: indexPath))
            print("clicking on direct name")
        }else{
            return
        }
        
        tableView.reloadData()
    }
    
    func getStaffTextName(indexPath: IndexPath) -> String{
        var row = indexPath.row
        if(unread.count != 0){
            row -= (unread.count + 1)
        }
        
        row -= 1 //big staff header
        
        var size = 0
        for i in 0 ... (staff.count - 1) {
            row -= 1
            let staff_type_name = staffKeys[i]
            if(staff_type_hiding.contains(staff_type_name)){
                size = 0
            }else{
                size = (staff[staff_type_name]?.count)!
            }
            if(row >= 0 && row < size){
                return (staff[staff_type_name]?[row])!
            }
            row -= size
            
        }
        return ""
    }
    
    func getDirectUserName(indexPath: IndexPath) -> String{
        var row = indexPath.row
        
        if(unread.count > 0){
            row -= 1
            if(unread_showing){
                row -= (unread.count)//for title text
            }
        }
        row -= 2 //for users and staff 'big' headers
        if(staff_showing){
            row -= (staff.count) //for staff section
            row -= getStaffCount() //for all the staff
        }
        
        return users[row][0]

    }
    
    func setConversationMembers(name: String){
        print([usersIDs[name]!])
        UserDefaults.standard.set([usersIDs[name]!], forKey: "conversationMembers")
        print(UserDefaults.standard.array(forKey: "conversationMembers"))
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    
    
    
    
}
