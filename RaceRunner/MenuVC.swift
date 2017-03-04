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
    fileprivate static let rowHeight: CGFloat = 50.0
    fileprivate static let realRunMessage = "There is a real run in progress. Please click the Run menu item and stop the run before attempting to simulate a run."
    fileprivate static let okButtonText = "OK"
    fileprivate static let gpxFile = "iSmoothRun"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTable.separatorStyle = .none
        menuTable.backgroundColor = UIColor.clear
        menuTable.scrollsToTop = false
        menuTable.delegate = self
        menuTable.dataSource = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controllerLabels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
            cell!.backgroundColor = UIColor.clear
            cell!.textLabel?.textColor = UiConstants.intermediate2Color
            let selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            cell!.textLabel?.textAlignment = NSTextAlignment.center
            cell!.selectedBackgroundView = selectedBackgroundView
            cell!.textLabel?.font = UIFont(name: UiConstants.titleFont, size: UiConstants.titleFontSize)
        }
        cell!.textLabel?.text = controllerLabels[indexPath.row]
        cell!.textLabel?.attributedText = UiHelpers.letterPressedText(controllerLabels[indexPath.row])
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MenuVC.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if controllerLabels[indexPath.row] == "History" {
            logTypeToShow = .history
        }
        else if controllerLabels[indexPath.row] == "CLLocations" || controllerLabels[indexPath.row] == "GPX File" {
            logTypeToShow = .simulate
        }
        if (controllerLabels[indexPath.row] == "CLLocations" || controllerLabels[indexPath.row] == "GPX File") && RunModel.runModel.realRunInProgress {
            let alertController = UIAlertController(title: "😢", message: MenuVC.realRunMessage, preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: MenuVC.okButtonText, style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            performSegue(withIdentifier: panSegues[indexPath.row], sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pan log" {
            let logVC: LogVC = segue.destination as! LogVC
            logVC.logType = logTypeToShow
        }
        else if segue.identifier == "pan GPX run" {
            let runVC: RunVC = segue.destination as! RunVC
            runVC.gpxFile = MenuVC.gpxFile
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
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
