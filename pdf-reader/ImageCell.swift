//
//  ImageCell.swift
//  pdf-reader
//
//  Created by Thomas Durand on 20/11/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageLabel: UILabel!
    
    // Allow to track if the cell is still visible of if it's been reused for async tasks
    var indexPath: NSIndexPath!
}