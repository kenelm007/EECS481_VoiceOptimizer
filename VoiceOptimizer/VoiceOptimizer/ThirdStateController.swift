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
    var text = ""
    
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
        optimize(url: getRecordURL())
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
        do {
            try soundPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            assert(false, "Fail to initial sound player")
        }
        soundPlayer.prepareToPlay()
        soundPlayer.volume = 1.0
        soundPlayer.enableRate = true
        soundPlayer.rate = 1.5
    }
    
    func recognizeFile(url:URL){
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current locale
            return
        }
        if !myRecognizer.isAvailable {
            print ("The recognizer is not available")
            return
        }
        let request = SFSpeechURLRecognitionRequest(url: url)
        myRecognizer.recognitionTask(with: request) { (result, error) in
            guard let result = result else {
                print ("Fail to recognize the audio")
                return
            }
            if result.isFinal {
                self.text = "\(result.bestTranscription.formattedString)"
                print (self.text)
                self.rec_text.text = self.text
            }
        }
        
        return
    }
    
    @IBAction func playvoice(_ sender: Any) {
        preparePlayer(url: getAudioURL())
        print("play voice!")
        soundPlayer.play()

    }
    
    func filter(array: Array<Float>) -> Array<Float> {
        var newRightArray = array.sorted{ abs($0) < abs($1) }
        let threshold = abs(newRightArray[Int(Float(newRightArray.count) * 0.62)])
        let sample = 200
        var i = 0
        var rightArray = array
        while i < rightArray.count / sample {
            let first = i * sample
            let last = min((i + 1) * sample, rightArray.count)
            if max(abs(rightArray[first...last].max()!), -abs(rightArray[first...last].min()!)) < threshold {
                rightArray[first...last] = []
                i -= 1
            }
            i += 1
        }
        return rightArray
        
    }

    func optimize(url: URL) {
        var file: AVAudioFile!
        do {
            file = try AVAudioFile(forReading: url)
        } catch {
            assert(false, "Fail to get record file url")
        }
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
        do {
            try file.read(into: buf) // You probably want better error handling
        } catch {
            assert(false, "Fail to read from record file")
        }
        
        var rightArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        // TODO: left array
        
        rightArray = filter(array: rightArray)
        
        let newbuf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(rightArray.count))
        newbuf.frameLength = UInt32(rightArray.count)
        for j in 0...rightArray.count-1 {
            newbuf.floatChannelData?.pointee[j] = rightArray[j]
            newbuf.floatChannelData?.advanced(by: 1).pointee[j] = rightArray[j]
        }
        
        let setting = [AVSampleRateKey: 44100,
                       AVFormatIDKey: kAudioFormatLinearPCM,
                       AVNumberOfChannelsKey: 2] as [String : Any]
        
        var newfile = AVAudioFile()
        do {
            newfile = try AVAudioFile(forWriting: getAudioURL(), settings: setting)
        } catch {
            assert(false, "Fail to open audio file")
        }
        do {
            try newfile.write(from: newbuf)
        } catch {
            assert(false, "Fail to write into file")
        }
    }
    
    func getRecordURL() -> URL{
        print("Getting URL")
        let path = (getCacheDirectory() as NSString).appendingPathComponent(filename)
        let filepath = URL(fileURLWithPath: path)
        return filepath
    }
    @IBAction func test(_ sender: Any) {
        optimize(url: getTestURL())
        recognizeFile(url: getTestURL())
        recognizeFile(url: getAudioURL())
        
    }
    
    func getTestURL() -> URL{
        let url = Bundle.main.url(forResource: "test", withExtension: "wav")
        return url!;
    }
    
    @IBAction func playOriginal(_ sender: UIButton) {
        preparePlayer(url: getRecordURL())
        soundPlayer.play()
        
    }
    
}
