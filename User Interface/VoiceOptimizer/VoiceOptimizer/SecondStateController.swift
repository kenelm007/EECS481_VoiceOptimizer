//
//  SecondStateController.swift
//  VoiceOptimizer
//
//  Created by Shuoyang Cui on 10/30/16.
//  Copyright © 2016 Shuoyang Cui. All rights reserved.
//

import UIKit

class SecondStateController: UIViewController {
    
    var seconds = 0
    var minutes = 0
    var timer = NSTimer()
    
    @IBOutlet weak var timerLabel: UILabel!
    
    
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
        // timerLabel.center = self.view.center
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "background")!
        self.view.insertSubview(backgroundImage, atIndex: 0)
      
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SecondStateController.updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTime() {
        seconds += 1
        if (seconds == 60){
            minutes += 1
            seconds = 0
        }
        timerLabel.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: Action
    
    @IBAction func stopRecording(sender: AnyObject) {
        // TODO: stop recording function
        print("stop recording")
        timer.invalidate()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let thirdController = storyboard.instantiateViewControllerWithIdentifier("thirdState") as! ThirdStateController
        presentViewController(thirdController, animated: false, completion: nil)

    }
    

    
}
