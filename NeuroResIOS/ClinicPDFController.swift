//
//  PDFController.swift
//  NeuroResIOS
///Users/c1mckay/Desktop/ucsdreshandbook 2017 2018.pdf
//  Created by Charles McKay on 8/24/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit

class ClinicPDFController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pdf = Bundle.main.url(forResource: "clinicsessions", withExtension: "pdf", subdirectory: nil, localization: nil)
        let req = NSURLRequest(url: pdf!)
        let webView = UIWebView(frame: CGRect(x:0,y:0,width:self.view.frame.size.width,height: self.view.frame.size.height-40)) //Adjust view area here
        webView.loadRequest(req as URLRequest)
        self.view.addSubview(webView)
        
        if self.revealViewController() != nil {
            menuButton.target = self//.revealViewController()
            menuButton.action = #selector(PDFController.menuClick(_:))
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatController.onConversationPaneClick))
        self.view.addGestureRecognizer(tap)
        
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left, .up, .down]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(ChatController.handleSwipe))
            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
        }
    }
    
    @objc func menuClick(_ sender : Any){
        let controller = self.revealViewController()
        controller?.revealToggle(controller)
    }
    
    func onConversationPaneClick(_ sender: Any){
        print("conversation pane clicked")
        hideSlideMenu()
    }
    
    func hideSlideMenu(){
        if(slideMenuShowing()){
            let controller = self.revealViewController()
            controller?.revealToggle(controller)
        }
    }
    
    func slideMenuShowing() -> Bool {
        return self.revealViewController().frontViewPosition.rawValue == ChatController.MENU_MODE;
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
}
