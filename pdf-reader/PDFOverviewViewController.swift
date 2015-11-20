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
    
    var widthForPage: CGFloat {
        return UIScreen.mainScreen().bounds.width/4
    }
    
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
    
    func rectFromPDFWithPage(page: Int) -> CGRect? {
        guard let document = self.document else { print("no document"); return nil }
        
        let docPage = CGPDFDocumentGetPage(document, page)
        let pageRect:CGRect = CGPDFPageGetBoxRect(docPage, .MediaBox);
        
        return pageRect
    }
    
    func imageFromPDFWithPage(page: Int) -> UIImage? {
        guard let document = self.document else { print("no document"); return nil }
        let docPage = CGPDFDocumentGetPage(document, page)
        let pageRect = self.rectFromPDFWithPage(page)!
        
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let pageSize = self.rectFromPDFWithPage(indexPath.row+1)?.size else { return CGSize.zero }
        
        let scale = widthForPage/pageSize.width
        let height = pageSize.height*scale
        return CGSize(width: widthForPage, height: height);
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
}
