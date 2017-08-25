//
//  PDFController.swift
//  NeuroResIOS
///Users/c1mckay/Desktop/ucsdreshandbook 2017 2018.pdf
//  Created by Charles McKay on 8/24/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit

class PDFController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pdf = Bundle.main.url(forResource: "reshandbook", withExtension: "pdf", subdirectory: nil, localization: nil)
        let req = NSURLRequest(url: pdf!)
        let webView = UIWebView(frame: CGRect(x:0,y:0,width:self.view.frame.size.width,height: self.view.frame.size.height-40)) //Adjust view area here
        webView.loadRequest(req as URLRequest)
        self.view.addSubview(webView)
        
        if self.revealViewController() != nil {
            menuButton.target = self//.revealViewController()
            menuButton.action = #selector(PDFController.menuClick(_:))
        }
    }
    
    func menuClick(_ sender : Any){
        let controller = self.revealViewController()
        controller?.revealToggle(controller)
    }
}
