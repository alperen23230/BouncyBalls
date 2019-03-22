//
//  CgPointExtension.swift
//  BounceBalls
//
//  Created by Alperen Ünal on 20.03.2019.
//  Copyright © 2019 Alperen Ünal. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint{
    static public func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
}
