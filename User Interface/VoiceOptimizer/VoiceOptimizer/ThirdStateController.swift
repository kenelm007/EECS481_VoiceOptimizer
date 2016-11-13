//
//  ThirdStateController.swift
//  VoiceOptimizer
//
//  Created by Shuoyang Cui on 10/30/16.
//  Copyright © 2016 Shuoyang Cui. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ThirdStateController: UIViewController {
    @IBOutlet weak var rec_text: UITextView!
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var audioname = "audiofile.wav"
    var filename = "record.m4a"
    var res = ""
    
    
    
    
    
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
        optimize()
        recognizeFile(url: getAudioURL())
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: Action
    @IBAction func recordAnother(_ sender: UIButton) {
        print("record another")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstController = storyboard.instantiateViewController(withIdentifier: "firstState") as! ViewController
        present(firstController, animated: false, completion: nil)

        
    }
    
    func getCacheDirectory() ->String{
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
    
    
    func getAudioURL() -> URL{
        let path = (getCacheDirectory() as NSString).appendingPathComponent(audioname)
        let filepath = URL(fileURLWithPath: path)
        return filepath
    }
    
    func preparePlayer(url: URL){
        try! soundPlayer = AVAudioPlayer(contentsOf: url)
        soundPlayer.prepareToPlay()
        soundPlayer.volume = 1.0
        soundPlayer.enableRate = true
        soundPlayer.rate = 1.5
    }
    
    func recognizeFile(url:URL){
        //var res = ""
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current locale
            return
        }
        if !myRecognizer.isAvailable {
            // The recognizer is not available right now
            print ("error1")
            return
        }
        let request = SFSpeechURLRecognitionRequest(url: url)
        myRecognizer.recognitionTask(with: request) { (result, error) in
            guard let result = result else {
                // Recognition failed, so check error for details and handle it
                print ("error2")
                return
            }
            if result.isFinal {
                self.res = "\(result.bestTranscription.formattedString)"
                print (self.res)
                self.rec_text.text = self.res
            }
        }
        
        return
    }
    
    @IBAction func playvoice(_ sender: Any) {
        preparePlayer(url: getAudioURL())
        print("play voice!")
        soundPlayer.play()
        

    }
    
    func calculateThreshold(array: Array<Float>) -> Float {
        // median
        var newRightArray = array.sorted{ abs($0) < abs($1) }
        return abs(newRightArray[Int(Float(newRightArray.count) * 0.62)])
    }

    func optimize() {
        var file: AVAudioFile!
        do {
            file = try AVAudioFile(forReading: getRecordURL())
        } catch {
            print ("err01")
        }
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
        do {
            try file.read(into: buf) // You probably want better error handling
        } catch {
            print ("err02")
        }
        
        var rightArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        //var leftArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[1], count:Int(buf.frameLength)))
        
        //filter
        let sample = 200
        let threshold = calculateThreshold(array: rightArray)
        var i = 0
        while i < rightArray.count / sample { // TODO filter right and left track at the same time
            let first = i * sample
            let last = min((i + 1) * sample, rightArray.count)
            if max(rightArray[first...last].max()!, -rightArray[first...last].min()!) < threshold {
                rightArray[first...last] = []
                i -= 1
            }
            i += 1
        }
        print (rightArray.count)
        
        let newbuf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(rightArray.count))
        newbuf.frameLength = UInt32(rightArray.count)
        for j in 0...rightArray.count-1 {
            newbuf.floatChannelData?.pointee[j] = rightArray[j]
            newbuf.floatChannelData?.advanced(by: 1).pointee[j] = rightArray[j] // TODO modify
        }
        
        let setting = [AVSampleRateKey: 44100,
                       AVFormatIDKey: kAudioFormatLinearPCM,
                       AVNumberOfChannelsKey: 2] as [String : Any]
        
        let newfile = try! AVAudioFile(forWriting: getAudioURL(), settings: setting)
        do {
            try newfile.write(from: newbuf)
            print ("optimized")
        } catch {
            print ("err03")
        }
    }
    func getRecordURL() -> URL{
        print("Getting URL")
        let path = (getCacheDirectory() as NSString).appendingPathComponent(filename)
        let filepath = URL(fileURLWithPath: path)
        return filepath
    }

    // TODO: For testing, remove later
    
    @IBAction func playOriginal(_ sender: UIButton) {
        preparePlayer(url: getRecordURL())
        soundPlayer.play()
        
    }
    
}
