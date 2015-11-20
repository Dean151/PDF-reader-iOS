//
//  PDFReaderViewController.swift
//  pdf-reader
//
//  Created by Thomas Durand on 20/11/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit

class PDFReaderViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var overviewButton: UIBarButtonItem!
    
    var shouldShowPage: Int?
    
    var pdf: PDF? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        guard let pdf = self.pdf else {
            print("no pdf");
            self.navigationItem.rightBarButtonItem?.enabled = false
            return
        }
        self.navigationItem.title = pdf.name
        self.navigationItem.rightBarButtonItem?.enabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.webview.delegate = self
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showOverview" {
            if let pdf = self.pdf {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PDFOverviewViewController
                controller.pdf = pdf
                controller.parentVC = self
            }
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let page = self.shouldShowPage {
            self.goToPage(page)
        }
    }
    
    func goToPage(page: Int) {
        guard let url = pdf?.fileURL else { return }
        let paddingSize = 10
        
        let document = CGPDFDocumentCreateWithURL(url)
        let nbPages = CGPDFDocumentGetNumberOfPages(document)
        
        let allHeight = self.webview.scrollView.contentSize.height
        let allPadding = CGFloat(paddingSize * (nbPages+1))
        let pageHeight = (allHeight-allPadding)/CGFloat(nbPages)
        
        if page <= nbPages && page >= 0 {
            let offsetPoint = CGPointMake(0, CGFloat(paddingSize*(page-1))+(pageHeight*CGFloat(page-1)))
            self.webview.scrollView.setContentOffset(offsetPoint, animated: false)
        }
    }
}

