//
//  ThirdStateController.swift
//  VoiceOptimizer
//
//  Created by Shuoyang Cui on 10/30/16.
//  Copyright © 2016 Shuoyang Cui. All rights reserved.
//

import UIKit

class ThirdStateController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        func assignbackground(){
        //            let background = UIImage(named: "background")
        //
        //            var imageView : UIImageView!
        //            imageView = UIImageView(frame: view.bounds)
        //            imageView.contentMode =  UIViewContentMode.ScaleAspectFill
        //            imageView.clipsToBounds = true
        //            imageView.image = background
        //            imageView.center = view.center
        //            view.addSubview(imageView)
        //            self.view.sendSubviewToBack(imageView)
        //        }
        //        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "background")!
        self.view.insertSubview(backgroundImage, atIndex: 0)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: Action
    @IBAction func recordAnother(sender: UIButton) {
        print("record another")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstController = storyboard.instantiateViewControllerWithIdentifier("firstState") as! ViewController
        presentViewController(firstController, animated: false, completion: nil)

        
    }
}