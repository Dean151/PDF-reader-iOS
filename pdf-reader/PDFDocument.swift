//
//  PDFDocument.swift
//  pdf-reader
//
//  Created by Thomas Durand on 22/11/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import Foundation
import UIKit

enum PDFList: Int {
    case SamplePDF=0, DocumentPDF, LatexSample, iOS
    
    var name: String {
        switch self {
        case .SamplePDF:
            return "PDF Sample"
        case .DocumentPDF:
            return "PDF Document"
        case .LatexSample:
            return "LaTeX Sample"
        case .iOS:
            return "iOS Reverse Engineering"
        }
    }
    
    var fileURL: NSURL? {
        switch self {
        case .SamplePDF:
            return NSBundle.mainBundle().URLForResource("pdfsample", withExtension: "pdf")
        case .DocumentPDF:
            return NSBundle.mainBundle().URLForResource("pdfdocuments", withExtension: "pdf")
        case .LatexSample:
            return NSBundle.mainBundle().URLForResource("latexsample", withExtension: "pdf")
        case .iOS:
            return NSBundle.mainBundle().URLForResource("iosreverseengineering", withExtension: "pdf")
        }
    }
    
    static let count: Int = {
        var max: Int = 0
        while let _ = PDFList(rawValue: ++max) {}
        return max
    }()
}

enum PDFDocumentError: ErrorType {
    case UrlNotValid, BadDocumentType
}

class PDFDocument {
    let name: String
    var url: NSURL? = nil
    var document: CGPDFDocument? = nil
    
    init(name: String, url: NSURL) throws {
        self.name = name
        self.url = url
        guard let doc = CGPDFDocumentCreateWithURL(url) else {
            throw PDFDocumentError.BadDocumentType
        }
        self.document = doc
    }
    
    convenience init(pdfFromList: PDFList) throws {
        guard let url = pdfFromList.fileURL else { throw PDFDocumentError.UrlNotValid }
        try self.init(name: pdfFromList.name, url: url)
    }
    
    var numberOfPages: Int {
        return CGPDFDocumentGetNumberOfPages(self.document)
    }
    
    func isPageInDocument(page: Int) -> Bool {
        return page > 0 && page <= self.numberOfPages
    }
    
    // Thumbnail handling
    func PDFPage(page: Int) -> CGPDFPage? {
        guard let document = self.document else { print("no document"); return nil }
        return CGPDFDocumentGetPage(document, page)
    }
    
    func rectFromPDFWithPage(page: Int) -> CGRect? {
        guard let docPage = self.PDFPage(page) else { return nil }
        return CGPDFPageGetBoxRect(docPage, .MediaBox)
    }
    
    func imageFromPDFWithPage(page: Int) -> UIImage? {
        guard let docPage = self.PDFPage(page) else { return nil }
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
}