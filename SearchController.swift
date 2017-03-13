//
//  SearchController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/6/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit

class SearchController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var users:[String:Int] = [
        "R. Modir (Stroke)": 3,
        "F. Nahab (Movement)": 10,
        "M. Shtrahman (IOM)":0,
        "R. Kinkel (MS)":11,
        "K. Askim (Muscular)": 11,
        "C. Jablecki (Muscular)": 12,
        "J. Ravits (Muscular)": 11,
        "R. Mandeville (Muscular)": 3
    ]
    var resultKeys:[String] = []
    
    @IBOutlet weak var searchResultsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        resultKeys = Array(users.keys)
    }
    @IBOutlet weak var menuButton: UIBarButtonItem!

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

    var configured = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !configured{
            searchResultsTable.delegate = self
            searchResultsTable.dataSource = self
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
    
    func attributedString(from string: String, nonBoldRange: NSRange?) -> NSAttributedString {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
        ]
        let nonBoldAttribute = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.black
        ]
        let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
        if let range = nonBoldRange {
            attrStr.setAttributes(nonBoldAttribute, range: range)
        }
        return attrStr
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResult", for: indexPath) as! SearchResult
        
        let row = indexPath.row
        let user = resultKeys[row]
        let start = users[user]
        
        cell.resultText.attributedText = attributedString(from: user, nonBoldRange: NSMakeRange(start!,1))
        
        
        return cell
    }
}
