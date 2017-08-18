//
//  SearchController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/6/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit

class SearchController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //@IBOutlet weak var searchBar: UISearchBar!

    var visibleUsers:[String] = []
    
    var userToId : [String:Int] = [:]
    var userToStaff : [String: String] = [:]
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var searchResultsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchResultsTable.tableHeaderView = searchController.searchBar
        
        SlideMenuController.getUsers(token: SlideMenuController.getToken(), myName: SlideMenuController.getName()) { (users_ret: [String], userIDs_ret: [String:Int], staff_ret: [String:[String]]) in
            
            self.userToId = userIDs_ret
            for (email, users) in staff_ret{
                for user in users{
                    self.userToStaff[user] = email
                    self.visibleUsers.append(user)
                }
            }
            
            self.searchResultsTable.reloadData()
        }
        
    }
    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText_cased: String) {
        let searchText = searchText_cased.lowercased()
        
        visibleUsers.removeAll()
        for (user, staff) in userToStaff{
            let testString = user + " " + staff
            if (testString.lowercased().range(of: searchText) != nil || searchText.characters.count == 0){
                visibleUsers.append(user)
            }
        }
        
        searchResultsTable.reloadData()
    }
    
    /*func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearch searchString: String?) -> Bool {
        self.filterContentForSearchText(searchString!)
        return true
    }*/
    
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
        return visibleUsers.count
    }
    
    static func attributedString(from string: String, nonBoldRange: NSRange?) -> NSAttributedString {
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
        var text = searchController.searchBar.text
        
        
        let row = indexPath.row
        let email = visibleUsers[row]
        let searchText = email + " (" + userToStaff[email]! + ")"
        
        if let range = searchText.lowercased().range(of: text!.lowercased()) {
            let start = searchText.distance(from: searchText.startIndex, to: range.lowerBound)
            let length = (text?.characters.count)!
            cell.resultText.attributedText = SearchController.attributedString(from: searchText, nonBoldRange: NSMakeRange(start,length))
        }
        else{
            let start = 0
            let length = 0
            cell.resultText.attributedText = SearchController.attributedString(from: searchText, nonBoldRange: NSMakeRange(start,length))
        }
        
        let user_id_i = self.userToId[email]
        if(user_id_i != nil && !SlideMenuController.isOffline(user_id_i!)){
            cell.statusIco.image = UIImage(named: "online")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = visibleUsers[indexPath.row]
        let user_id = userToId[selectedUser]!
        SlideMenuController.setConversationMembers(id: user_id)
    }
}


extension SearchController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
