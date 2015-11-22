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
    var shouldReload = false
    
    var pdf: PDFDocument? {
        didSet {
            // Update the view.
            self.configureView()
            self.shouldReload = true
            self.shouldShowPage = nil
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        guard let pdf = self.pdf else {
            print("no pdf")
            return
        }
        self.navigationItem.title = pdf.name
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.webview.delegate = self
        self.configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Opening pdf file
        guard let url = pdf?.url else {
            print("no URL for file")
            self.navigationItem.rightBarButtonItem?.enabled = false
            let url = NSBundle.mainBundle().URLForResource("nofile", withExtension: "html")!
            let request = NSURLRequest(URL: url)
            webview.loadRequest(request)
            webview.scrollView.scrollEnabled = false
            return
        }
        if shouldReload {
            self.navigationItem.rightBarButtonItem?.enabled = true
            let request = NSURLRequest(URL: url)
            webview.loadRequest(request)
            webview.scrollView.scrollEnabled = true
            shouldReload = false
        } else {
            self.changePage()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showOverview" {
            guard let pdf = self.pdf else { return }
            
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PDFOverviewViewController
            controller.pdf = pdf
            controller.parentVC = self
            if let currentPage = self.currentPage {
                controller.currentPage = currentPage
            }
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.changePage()
    }
    
    // MARK: - Page Handling
    
    var currentPage: Int? {
        guard let nbPages = pdf?.numberOfPages else { return nil }
        let paddingSize: CGFloat = 10
        
        let allHeight = self.webview.scrollView.contentSize.height
        let allPadding = paddingSize * CGFloat(nbPages+1)
        let pageHeight = (allHeight-allPadding)/CGFloat(nbPages)
        
        let currentPage = Int( round(self.webview.scrollView.contentOffset.y / (paddingSize+pageHeight)) ) + 1
        return currentPage
    }
    
    func changePage() {
        if let page = self.shouldShowPage {
            self.shouldShowPage = nil // Prevent for changing page again
            self.goToPage(page)
        }
    }
    
    func goToPage(page: Int) {
        guard let nbPages = pdf?.numberOfPages else { return }
        let paddingSize: CGFloat = 10
        
        let allHeight = self.webview.scrollView.contentSize.height
        let allPadding = paddingSize * CGFloat(nbPages+1)
        let pageHeight = (allHeight-allPadding)/CGFloat(nbPages)
        
        if page <= nbPages && page >= 0 {
            let offsetPoint = CGPointMake(0, (paddingSize+pageHeight)*CGFloat(page-1))
            self.webview.scrollView.setContentOffset(offsetPoint, animated: false)
        }
    }
}

