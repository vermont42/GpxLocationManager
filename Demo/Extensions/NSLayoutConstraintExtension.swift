//
//  NSLayoutConstraintExtension.swift
//  CatBreeds
//
//  Created by Joshua Adams on 4/1/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
  @discardableResult func activate() -> NSLayoutConstraint {
    isActive = true
    return self
  }
}
