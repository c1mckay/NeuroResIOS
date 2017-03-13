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
    
    /**
    *   Delegate of the MenuVC
    */
    var delegate: SlideMenuDelegate?
    
    var  users:[[String]] = [
        ["T. Hemmen", "Stroke"],
        ["B. Huisa-Garate", "Stroke"],
        ["R. Modir", "Stroke"],
        ["K. Agrawal", "Stroke"],
        ["B. Meyer", "Stroke"],
        ["D. Meyer", "Stroke"],
        ["J. Shih", "Epilepsy"],
        ["C. Gonzalez", "NCC"],
        ["H. Ansari", "Headache"],
        ["S. Khoromi", "General"]
    ]
    
    var staff:[String:[String]] = [
        "Headache":[
        //    "H. Ansari"
        ],
        "Movement":[
        //    "F. Nahab"
        ],
        "Stroke":[
            "T. Hemmen",
            "B. Huisa-Garate",
            "R. Modir",
            "K. Agrawal",
            "B. Meyer"
        ],
        "Epilepsy":[
        //    "J. Shih",
        //    "E. Tecoma",
        //    "V. Iragui-Madoz"
        ],
        "NCC":[
        //    "C. Gonzalez",
        //    "J. Labuzetta"
        ],
        "General":[
        //    "S. Khoromi",
        //    "S. Siavoshi",
        //    "R. Ellis",
        //    "R. Haas"
        ],
        "IOM":[
        //    "J. Gertsch",
        //    "M. Shtrahman"
        ],
        "Memory":[
        //    "S. Yan"
        ]
    ]
    
    var unread:[String] = ["C. McKay"]

    var staffKeys:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        staffKeys = Array(staff.keys)
        // Do any additional setup after loading the view.
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
        }
        let staff_section = staff.count + 1
        let users_section = users.count + 1
        
        
        
        return unread_section + staff_section + getStaffCount() + users_section + 1//1 is the last row for more
    }
    
    func getStaffCount() -> Int{
        var staff_subsection = 0;
        for(_, staff_names) in staff{
            staff_subsection += staff_names.count
        }
        return staff_subsection
    }
    
    func unreadHeader(indexPath: IndexPath) -> Bool{
        return unread.count > 0 && indexPath.row == 0
    }
    
    func unreadCell(indexPath: IndexPath) -> Bool{
        if(unread.count == 0){
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
        row -= (staff.count + 1)
        row -= getStaffCount()
        return row == 0
    }
    
    func staffTypeCell(indexPath: IndexPath) -> Bool{
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
                row -= (staff[staffKeys[i]]?.count)!
            }
        }
        return false
    }
    
    func staffNameCell(indexPath: IndexPath) -> Bool{
        var row = indexPath.row
        if(unread.count != 0){
            row -= (unread.count + 1)
        }
        
        row -= 1
        
        var size = 0
        if(staff.count > 0){
            for i in 0 ... (staff.count - 1) {
                row -= 1
                size = (staff[staffKeys[i]]?.count)!
            
                if(row >= 0 && row < size){
                    return true
                }
                row -= size
            }
        }
        return false
    }
    
    
    
    func header(indexPath: IndexPath) -> Bool{
        return unreadHeader(indexPath: indexPath) || staffHeader(indexPath: indexPath) || usersHeader(indexPath: indexPath)
    }
    
    //the ... show more people button
    func moreCell(indexPath: IndexPath) -> Bool{
        var unread_section = unread.count
        if(unread.count > 0){
            unread_section += 1
        }
        let staff_section = staff.count + 1
        let users_section = users.count + 1
        return unread_section + staff_section + users_section + getStaffCount() == indexPath.row
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
            
            return cell
        }else if(unreadCell(indexPath: indexPath)){ //for title text
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDescripCell", for: indexPath) as! ChatDescripCell
            
            cell.name.text = unread[indexPath.row - 1]
            
            return cell
        }else if(staffHeader(indexPath: indexPath)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatHeaderCell", for: indexPath) as! ChatHeaderCell
            
            cell.titleText.text = "Staff"
            
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
                    return cell
                }
                staffCell -= 1
                staffCell -= (staff[staffKeys[i]]?.count)!
            }
            
            return cell
        }else if(staffNameCell(indexPath: indexPath)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaffNameDescripCell", for: indexPath) as! StaffNameDescripCell
        
            var row = indexPath.row
            if(unread.count != 0){
                row -= (unread.count + 1)
            }
            
            row -= 1 //big staff header
            
            var size = 0
            for i in 0 ... (staff.count - 1) {
                row -= 1
                size = (staff[staffKeys[i]]?.count)!
                    
                if(row >= 0 && row < size){
                    cell.name.text = staff[staffKeys[i]]?[row]
                    return cell
                }
                row -= size
            
            }
            
            
            
            return cell
        }else if(usersHeader(indexPath: indexPath)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatHeaderCell", for: indexPath) as! ChatHeaderCell
            
            cell.titleText.text = "Private"
            
            return cell
        }else if(moreCell(indexPath: indexPath)){
            return tableView.dequeueReusableCell(withIdentifier: "MoreDescripCell", for: indexPath) as! MoreDescripCell        
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDescripCell", for: indexPath) as! ChatDescripCell
        
            var row = indexPath.row
    
            if(unread.count > 0){
                row -= (unread.count + 1)//for title text
            }
            row -= (staff.count + 1) //for staff section
            row -= 1 //for users header
            row -= getStaffCount() //for all the staff
        
            let username = users[row][0]
            cell.name.text = username
            
            cell.unreadCount.isHidden = true
        
        
            return cell
        }
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
