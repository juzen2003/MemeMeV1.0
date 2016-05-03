//
//  TextFieldDelegate.swift
//  MemeMeV1
//
//  Created by Yu-Jen Chang on 3/24/16.
//  Copyright © 2016 Yu-Jen Chang. All rights reserved.
//

import Foundation
import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // clear out default text
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}