//
//  MenuVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class MenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var menuTable: UITableView!
    
    var controllerLabels = ["Device GPS", "CLLocations", "GPX File", "History", "Settings"]
    var panSegues = ["pan run", "pan log", "pan GPX run", "pan log", "pan settings"]
    var selectedMenuItem: Int = 0
    var logTypeToShow: LogVC.LogType!
    private static let rowHeight: CGFloat = 50.0
    private static let realRunMessage = "There is a real run in progress. Please click the Run menu item and stop the run before attempting to simulate a run."
    private static let okButtonText = "OK"
    private static let gpxFile = "iSmoothRun"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTable.separatorStyle = .None
        menuTable.backgroundColor = UIColor.clearColor()
        menuTable.scrollsToTop = false
        menuTable.delegate = self
        menuTable.dataSource = self
        SettingsManager.getUnitType()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controllerLabels.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UiConstants.intermediate2Color
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.textLabel?.textAlignment = NSTextAlignment.Center
            cell!.selectedBackgroundView = selectedBackgroundView
            cell!.textLabel?.font = UIFont(name: UiConstants.titleFont, size: UiConstants.titleFontSize)
        }
        cell!.textLabel?.text = controllerLabels[indexPath.row]
        cell!.textLabel?.attributedText = UiHelpers.letterPressedText(controllerLabels[indexPath.row])
        return cell!
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MenuVC.rowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if controllerLabels[indexPath.row] == "History" {
            logTypeToShow = .History
        }
        else if controllerLabels[indexPath.row] == "CLLocations" || controllerLabels[indexPath.row] == "GPX File" {
            logTypeToShow = .Simulate
        }
        if (controllerLabels[indexPath.row] == "CLLocations" || controllerLabels[indexPath.row] == "GPX File") && RunModel.runModel.realRunInProgress {
            let alertController = UIAlertController(title: "😢", message: MenuVC.realRunMessage, preferredStyle: .Alert)
            let okAction: UIAlertAction = UIAlertAction(title: MenuVC.okButtonText, style: .Cancel, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            performSegueWithIdentifier(panSegues[indexPath.row], sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pan log" {
            let logVC: LogVC = segue.destinationViewController as! LogVC
            logVC.logType = logTypeToShow
        }
        else if segue.identifier == "pan GPX run" {
            let runVC: RunVC = segue.destinationViewController as! RunVC
            runVC.gpxFile = MenuVC.gpxFile
        }
    }
    
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue) {}
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        if let id = identifier{
            let unwindSegue = UnwindPanSegue(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
            })
            return unwindSegue
        }
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
