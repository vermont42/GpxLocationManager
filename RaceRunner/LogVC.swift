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
        case history
        case simulate
    }
    var logType: LogType!
    var gpxFile = ""
    var locFile = "iSmoothRun"
    fileprivate static let rowHeight: CGFloat = 92.0

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LogVC.rowHeight
    }
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        showMenuButton.setImage(UiHelpers.maskedImageNamed("menu", color: UiConstants.lightColor), for: UIControlState())
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewControllerTitle.text = viewControllerTitleText
        if logType == LogVC.LogType.history {
            viewControllerTitle.text = "History"
        }
        else if logType == LogVC.LogType.simulate {
            viewControllerTitle.text = "Simulate"
        }
        viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
        fetchRuns()
    }
    
    fileprivate func fetchRuns() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let context = CDManager.sharedCDManager.context
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Run", in: context!)
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        runs = (try? context?.fetch(fetchRequest)) as? [Run]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewDidAppear(animated)
    }
    
    @IBAction func showMenu(_ sender: UIButton) {
        showMenu()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? LogCell
        cell?.displayRun(runs![indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRun = indexPath.row
        if logType == .history {
            performSegue(withIdentifier: "pan details from log", sender: self)
        }
        else if logType == .simulate {
            performSegue(withIdentifier: "pan run from log", sender: self)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            CDManager.sharedCDManager.context.delete(runs![indexPath.row])
            CDManager.saveContext()
            runs!.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pan details from log" {
            let runDetailsVC: RunDetailsVC = segue.destination as! RunDetailsVC
            runDetailsVC.run = runs![selectedRun]
            runDetailsVC.logType = .history
        }
        else {
            if segue.identifier == "pan run from log" {
                let runVC: RunVC = segue.destination as! RunVC
                runVC.runToSimulate = runs![selectedRun]
            }
        }
    }
    
    @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {}
    
    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        if let id = identifier{
            let unwindSegue = UnwindPanSegue(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
                
            })
            return unwindSegue
        }
        
        return super.segueForUnwinding(to: toViewController, from: fromViewController, identifier: identifier)!
    }

}
