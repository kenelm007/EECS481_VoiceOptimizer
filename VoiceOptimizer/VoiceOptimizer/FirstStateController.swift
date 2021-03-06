//
//  ViewController.swift
//  VoiceOptimizer
//
//  Created by Shuoyang Cui on 10/23/16.
//  Copyright © 2016 Shuoyang Cui. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
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
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")!
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func recordVoice(_ sender: UIButton) {
        
        print("record voice")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = storyboard.instantiateViewController(withIdentifier: "secondState") as! SecondStateController
        present(secondController, animated: false, completion: nil)
        
        
    }
    
}

