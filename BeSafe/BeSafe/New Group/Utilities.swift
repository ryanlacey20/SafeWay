//
//  Utilities.swift
//  BeSafe
//
//  Created by Ryan Lacey on 13/11/2022.
//

import Foundation
class Utilities{
    static func isPasswordValid(_ password : String) -> Bool {
            
            let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
            return passwordTest.evaluate(with: password)
        }
}
