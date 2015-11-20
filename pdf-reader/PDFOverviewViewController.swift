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
    let widthForPage = UIScreen.mainScreen().bounds.width/4
    
    weak var parentVC: PDFReaderViewController?
    
    var pdf: PDF? {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        guard let url = self.pdf?.fileURL else { return }
        self.document = CGPDFDocumentCreateWithURL(url)
        self.collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: Selector("closeView:"))
    }
    
    func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageFromPDFWithPage(page: Int) -> UIImage? {
        guard let document = self.document else { print("no document"); return nil }
        let docPage = CGPDFDocumentGetPage(document, page)
        
        let width:CGFloat = widthForPage;
        var pageRect:CGRect = CGPDFPageGetBoxRect(docPage, .MediaBox);
        let pdfScale:CGFloat = width/pageRect.size.width;
        pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
        pageRect.origin = CGPointZero;
        
        UIGraphicsBeginImageContext(pageRect.size);
        let context:CGContextRef = UIGraphicsGetCurrentContext()!;
        CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
        CGContextFillRect(context,pageRect);
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0, pageRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(docPage, .MediaBox, pageRect, 0, true));
        CGContextDrawPDFPage(context, docPage);
        CGContextRestoreGState(context);
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    // MARK: - CollectionView
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let document = self.document else { return 0 }
        return CGPDFDocumentGetNumberOfPages(document)
    }
    
    // Limit : will work only with A4 pages
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = widthForPage
        let height = (width * 29.7) / 21
        return CGSize(width: width, height: height);
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCell
        
        let pageNumber = indexPath.row+1
        cell.pageLabel.text = "\(pageNumber)"
        
        if let image = self.imageFromPDFWithPage(pageNumber) {
            cell.imageView.image = image
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let parentVC = self.parentVC else { return }
        parentVC.shouldShowPage = indexPath.row+1
        self.closeView(self)
    }
}
