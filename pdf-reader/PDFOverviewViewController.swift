//
//  PDFOverviewViewController.swift
//  pdf-reader
//
//  Created by Thomas Durand on 20/11/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit

class PDFOverviewViewController: UICollectionViewController {
    var currentPage: Int?
    
    var widthForPage: CGFloat {
        return UIScreen.mainScreen().bounds.width/4
    }
    
    weak var parentVC: PDFReaderViewController?
    
    var pdf: PDFDocument? {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    var document: CGPDFDocument? {
        return self.pdf?.document
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("closeView"))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Go to", style: .Plain, target: self, action: Selector("choosePage"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let page = self.currentPage {
            guard let pdf = self.pdf where pdf.isPageInDocument(page) else { return }
            let indexPath = NSIndexPath(forRow: page-1, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
        }
    }
    
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func choosePage() {
        guard let pdf = self.pdf else { return }
        let alertController = UIAlertController(title: "Go to page", message: "Choose a page number between 1 and \(pdf.numberOfPages)", preferredStyle: .Alert)
        
        let sendAction = UIAlertAction(title: "Go", style: .Default, handler: { (action) in
            guard let pageTextFied = alertController.textFields?[0] else { return }
            guard let pageAsked = Int(pageTextFied.text!) else { return }
            guard pdf.isPageInDocument(pageAsked) else { return }
            
            self.goToPageInParentView(pageAsked)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addTextFieldWithConfigurationHandler({ (textField) in
            textField.placeholder = "Page number"
            textField.keyboardType = UIKeyboardType.NumberPad
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(sendAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func goToPageInParentView(page: Int) {
        guard let pdf = self.pdf where pdf.isPageInDocument(page) else { return }
        guard let parentVC = self.parentVC else { return }
        parentVC.shouldShowPage = page
        self.closeView()
    }
    
    // MARK: - CollectionView
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let pdf = self.pdf else { return 0 }
        return pdf.numberOfPages
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let pageSize = pdf?.rectFromPDFWithPage(indexPath.row+1)?.size else { return CGSize.zero }
        
        let scale = widthForPage/pageSize.width
        let height = pageSize.height*scale
        return CGSize(width: widthForPage, height: height);
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCell
        cell.indexPath = indexPath
        
        let pageNumber = indexPath.row+1
        cell.backgroundColor = UIColor.whiteColor()
        cell.pageLabel.text = "\(pageNumber)"
        cell.imageView.image = nil
        
        // Current page
        
        if pageNumber == currentPage {
            cell.layer.borderColor = CGColor.selectedBlue()
            cell.layer.borderWidth = 4
        } else {
            cell.layer.borderColor = nil
            cell.layer.borderWidth = 0
        }
        
        // Keeping expensive process to be in main queue for a smooth scrolling experience
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
        guard let image = self.pdf?.imageFromPDFWithPage(pageNumber) else { return } // If nil, useless to go further
            dispatch_async(dispatch_get_main_queue()) {
                // Changing the image only if the cell is on screen
                if cell.indexPath == indexPath {
                    cell.imageView.image = image
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.goToPageInParentView(indexPath.row+1)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
}

extension CGColor {
    static func selectedBlue() -> CGColor {
        return UIColor.selectedBlue().CGColor
    }
}
