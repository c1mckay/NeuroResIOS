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

    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDescripCell", for: indexPath) as! ChatDescripCell
        
        let row = indexPath.row
        
        let username = users[row][0]
        //let text = users[row][1]
        cell.name.text = username
        //cell.date.text = "date"
        //cell.content.text = text
        
        
        return cell
    }
}
