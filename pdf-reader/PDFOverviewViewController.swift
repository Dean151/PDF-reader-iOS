//
//  PDFOverviewViewController.swift
//  pdf-reader
//
//  Created by Thomas Durand on 20/11/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit

class PDFOverviewViewController: UICollectionViewController {
    var document: CGPDFDocumentRef?
    var currentPage: Int?
    
    var widthForPage: CGFloat {
        return UIScreen.mainScreen().bounds.width/4
    }
    
    weak var parentVC: PDFReaderViewController?
    
    var pdf: PDF? {
        didSet {
            self.configureView()
        }
    }
    
    var pdfPageNumber: Int {
        guard let document = self.document else { return 0 }
        return CGPDFDocumentGetNumberOfPages(document)
    }
    
    func configureView() {
        guard let url = self.pdf?.fileURL else { return }
        self.document = CGPDFDocumentCreateWithURL(url)
        self.collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("closeView"))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Go to", style: .Plain, target: self, action: Selector("choosePage"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let page = self.currentPage {
            let indexPath = NSIndexPath(forRow: page-1, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
        }
    }
    
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func choosePage() {
        let alertController = UIAlertController(title: "Go to page", message: "Choose a page number between 1 and \(self.pdfPageNumber)", preferredStyle: .Alert)
        
        let sendAction = UIAlertAction(title: "Go", style: .Default, handler: { (action) in
            guard let pageTextFied = alertController.textFields?[0] else { return }
            guard let pageAsked = Int(pageTextFied.text!) else { return }
            guard pageAsked > 0 && pageAsked <= self.pdfPageNumber else { return }
            
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
        guard let parentVC = self.parentVC else { return }
        parentVC.shouldShowPage = page
        self.closeView()
    }
    
    // MARK: pdf pages handling
    
    func rectFromPDFWithPage(page: Int) -> CGRect? {
        guard let document = self.document else { print("no document"); return nil }
        
        let docPage = CGPDFDocumentGetPage(document, page)
        let pageRect:CGRect = CGPDFPageGetBoxRect(docPage, .MediaBox)
        
        return pageRect
    }
    
    func imageFromPDFWithPage(page: Int) -> UIImage? {
        guard let document = self.document else { print("no document"); return nil }
        let docPage = CGPDFDocumentGetPage(document, page)
        let pageRect = self.rectFromPDFWithPage(page)!
        
        UIGraphicsBeginImageContext(pageRect.size)
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0)
        CGContextFillRect(context,pageRect)
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, 0.0, pageRect.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(docPage, .MediaBox, pageRect, 0, true))
        CGContextDrawPDFPage(context, docPage)
        CGContextRestoreGState(context)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    // MARK: - CollectionView
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pdfPageNumber
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let pageSize = self.rectFromPDFWithPage(indexPath.row+1)?.size else { return CGSize.zero }
        
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
        let image = self.imageFromPDFWithPage(pageNumber)
            dispatch_async(dispatch_get_main_queue()) {
                // Changing the image only if the cell is on screen
                if cell.indexPath == indexPath {
                    cell.imageView.image = image;
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
