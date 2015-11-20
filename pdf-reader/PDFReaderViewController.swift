//
//  PDFReaderViewController.swift
//  pdf-reader
//
//  Created by Thomas Durand on 20/11/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit

class PDFReaderViewController: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    
    var pdf: PDF? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        guard let pdf = self.pdf else { print("no pdf"); return }
        self.navigationItem.title = pdf.name
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Opening pdf file
        guard let url = pdf?.fileURL else { print("no URL for file"); return }
        let request = NSURLRequest(URL: url)
        webview.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

