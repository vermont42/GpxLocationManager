//
//  ChildVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class ChildVC: UIViewController {    
    override func viewDidLoad() {
        setupSwipeGestureRecognizer()
    }
    
    func setupSwipeGestureRecognizer() {
        let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ChildVC.showMenu))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    func showMenu() {
        self.performSegue(withIdentifier: "unwind pan", sender: self)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
