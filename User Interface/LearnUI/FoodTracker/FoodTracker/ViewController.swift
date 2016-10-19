//
//  ViewController.swift
//  FoodTracker
//
//  Created by Shuoyang Cui on 10/16/16.
//  Copyright © 2016 Shuoyang Cui. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController, UITextFieldDelegate {
    // MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealNameLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        mealNameLabel.text = textField.text
    }
    
    // MARK: Actions
    
    @IBAction func setDefaultLabelText(sender: UIButton) {
        mealNameLabel.text = "Default Text"
    }
    
    
    @IBAction func onPlay(sender: AnyObject) {
        print("Hello World onPlay")
    }

    @IBAction func onEnd(sender: AnyObject) {
        print("Hello World onEnd")
    }
    
    @IBAction func onPlayEdited(sender: AnyObject) {
        print("Hello World onPlayEdited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

