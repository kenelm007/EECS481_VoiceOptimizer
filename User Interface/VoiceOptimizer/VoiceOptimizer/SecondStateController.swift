//
//  SecondStateController.swift
//  VoiceOptimizer
//
//  Created by Shuoyang Cui on 10/30/16.
//  Copyright © 2016 Shuoyang Cui. All rights reserved.
//

import UIKit
import AVFoundation

class SecondStateController: UIViewController {
    
    var seconds = 0
    var minutes = 0
    var timer = Timer()
    var soundRecorder : AVAudioRecorder!
    var filename = "record.m4a"
    var res = ""
    
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
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")!
        self.view.insertSubview(backgroundImage, at: 0)
      
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SecondStateController.updateTime), userInfo: nil, repeats: true)
        setupsession()
        setupRecorder()
        soundRecorder.record()
    }
    
    func setupRecorder(){
        let recordSettings = [AVSampleRateKey: 44100,
                              AVFormatIDKey: kAudioFormatAppleLossless,
                              AVNumberOfChannelsKey: 2,
                              AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey: 320000] as [String : Any]
        do {
            try soundRecorder = AVAudioRecorder(url: getRecordURL(), settings: recordSettings)
        } catch {
            assert(false, "Fail to initial sound recorder")
        }
        soundRecorder.prepareToRecord()
    }

    func setupsession(){
        let session: AVAudioSession = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try session.setActive(true)
        } catch {
            assert(false,"Fail to setup session")
        }
        
    }
    
    func getCacheDirectory() ->String{
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
    
    func getRecordURL() -> URL{
        let path = (getCacheDirectory() as NSString).appendingPathComponent(filename)
        let filepath = URL(fileURLWithPath: path)
        return filepath
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
    
    @IBAction func stopRecording(_ sender: AnyObject) {
        
        print("stop recording")
        timer.invalidate()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let thirdController = storyboard.instantiateViewController(withIdentifier: "thirdState") as! ThirdStateController
        soundRecorder.stop()

        present(thirdController, animated: false, completion: nil)
        
    }
    
}
