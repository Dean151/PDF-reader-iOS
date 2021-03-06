//
//  PDFReaderViewController.swift
//  pdf-reader
//
//  Created by Thomas Durand on 20/11/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit
import WebKit

class PDFReaderViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var overviewButton: UIBarButtonItem!
    var webview: WKWebView!
    
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
            print("no pdf");
            return
        }
        self.navigationItem.title = pdf.name
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.webview = WKWebView(frame: self.view.bounds)
        self.webview.navigationDelegate = self
        if let navBarOffset = self.navigationController?.navigationBar.frame.size.height {
             // Preventing having page under Navigation Controller
            self.webview.scrollView.contentInset = UIEdgeInsets(top: navBarOffset, left: 0, bottom: 0, right: 0)
        }
        self.view.addSubview(self.webview)
        
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
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
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
            var offsetPoint = CGPointMake(0, (paddingSize+pageHeight)*CGFloat(page-1))
            if let navBarOffset = self.navigationController?.navigationBar.frame.size.height {
                offsetPoint.y -= navBarOffset + paddingSize // Preventing having page under Navigation Controller
            }
            self.webview.scrollView.setContentOffset(offsetPoint, animated: false)
        }
    }
}

