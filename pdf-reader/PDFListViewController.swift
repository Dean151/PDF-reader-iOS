//
//  PDFListViewController.swift
//  pdf-reader
//
//  Created by Thomas Durand on 20/11/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit



class PDFListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        if let split = self.splitViewController {
            split.preferredDisplayMode = .PrimaryOverlay
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let pdf = PDFList(rawValue: indexPath.row) {
                    let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PDFReaderViewController
                    do {
                        controller.pdf = try PDFDocument(pdfFromList: pdf)
                    } catch {
                        print("PDF could not be created")
                    }
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PDFList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.textLabel!.text = PDFList(rawValue: indexPath.row)!.name
        cell.selectedBackgroundView?.backgroundColor = UIColor.blueColor()
        
        let background = UIView()
        background.backgroundColor = UIColor.selectedBlue()
        background.layer.masksToBounds = true
        cell.selectedBackgroundView = background
        
        return cell
    }

}

extension UIColor {
    static func selectedBlue() -> UIColor {
        return UIColor(red: (76.0/255.0), green: (161.0/255.0), blue: (255.0/255.0), alpha: 1.0)
    }
}