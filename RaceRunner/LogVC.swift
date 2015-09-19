//
//  LogVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class LogVC: ChildVC, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var viewControllerTitle: UILabel!
    @IBOutlet var showMenuButton: UIButton!
    var viewControllerTitleText: String!
    var context: NSManagedObjectContext!
    var runs: [Run]?
    var selectedRun = 0
    enum LogType {
        case History
        case Simulate
    }
    var logType: LogType!
    var gpxFile = ""
    var locFile = "iSmoothRun"
    private static let rowHeight: CGFloat = 92.0

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return LogVC.rowHeight
    }
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        showMenuButton.setImage(UiHelpers.maskedImageNamed("menu", color: UiConstants.lightColor), forState: .Normal)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.viewControllerTitle.text = viewControllerTitleText
        if logType == LogVC.LogType.History {
            viewControllerTitle.text = "History"
        }
        else if logType == LogVC.LogType.Simulate {
            viewControllerTitle.text = "Simulate"
        }
        viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
        fetchRuns()
    }
    
    private func fetchRuns() {
        let fetchRequest = NSFetchRequest()
        let context = CDManager.sharedCDManager.context
        fetchRequest.entity = NSEntityDescription.entityForName("Run", inManagedObjectContext: context)
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        runs = (try? context.executeFetchRequest(fetchRequest)) as? [Run]
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        super.viewDidAppear(animated)
    }
    
    @IBAction func showMenu(sender: UIButton) {
        showMenu()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let runs = runs {
            return runs.count
        }
        else if !SettingsManager.getAlreadyMadeSampleRun() {
            if let parser = GpxParser(file: locFile) {
                var (name, coordinates): (String, [CLLocation]) = parser.parse()
                runs = [RunModel.addRun(coordinates, customName: name, timestamp: coordinates[0].timestamp)]
                SettingsManager.setAlreadyMadeSampleRun(true)
            }
            else {
                abort()
            }
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? LogCell
        cell?.displayRun(runs![indexPath.row])
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRun = indexPath.row
        if logType == .History {
            performSegueWithIdentifier("pan details from log", sender: self)
        }
        else if logType == .Simulate {
            performSegueWithIdentifier("pan run from log", sender: self)
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            CDManager.sharedCDManager.context.deleteObject(runs![indexPath.row])
            CDManager.saveContext()
            runs!.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pan details from log" {
            let runDetailsVC: RunDetailsVC = segue.destinationViewController as! RunDetailsVC
            runDetailsVC.run = runs![selectedRun]
            runDetailsVC.logType = .History
        }
        else {
            if segue.identifier == "pan run from log" {
                let runVC: RunVC = segue.destinationViewController as! RunVC
                runVC.runToSimulate = runs![selectedRun]
            }
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

}