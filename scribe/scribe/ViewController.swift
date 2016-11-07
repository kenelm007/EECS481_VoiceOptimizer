//
//  ViewController.swift
//  scribe
//
//  Created by 盛思远 on 10/26/16.
//  Copyright © 2016 盛思远. All rights reserved.
//

import UIKit
import AVFoundation
import Speech


class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate{

    @IBOutlet weak var RecordBTN: UIButton!
    @IBOutlet weak var PlayBTN: UIButton!
    
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var audioname = "audiofile.wav"
    var filename = "record.m4a"
    var res = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupsession()
        setupRecorder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupsession(){
        let session: AVAudioSession = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
        try! session.setActive(true)
        
    }
    func setupRecorder(){
        let recordSettings = [AVSampleRateKey: 44100,
                              AVFormatIDKey: kAudioFormatAppleLossless,
                              AVNumberOfChannelsKey: 2,
                              AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey: 320000] as [String : Any]
        //var error: NSError?
        try! soundRecorder = AVAudioRecorder(url: getRecordURL(), settings: recordSettings)
        soundRecorder.delegate = self
        soundRecorder.prepareToRecord()
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
    
    func getAudioURL() -> URL{
        let path = (getCacheDirectory() as NSString).appendingPathComponent(audioname)
        let filepath = URL(fileURLWithPath: path)
        return filepath
    }

    @IBAction func record(_ sender: Any) {
        if RecordBTN.titleLabel?.text == "Record"{
            
            soundRecorder.record()
            RecordBTN.setTitle("Stop", for: .normal)
            PlayBTN.isEnabled = false
        }
        else{
            soundRecorder.stop()
            RecordBTN.setTitle("Record", for: .normal)
            PlayBTN.isEnabled = false
        }
    }
    
    @IBAction func playsound(_ sender: Any) {
        optimize()
        if PlayBTN.titleLabel?.text == "Play"{
            RecordBTN.isEnabled = false
            preparePlayer()
            PlayBTN.setTitle("Stop", for: .normal)
            soundPlayer.play()
        }
        else{
            soundPlayer.stop()
            PlayBTN.setTitle("Play", for: .normal)
        }
    }
    
    
    func preparePlayer(){
        try! soundPlayer = AVAudioPlayer(contentsOf: getAudioURL())
        soundPlayer.delegate = self;
        soundPlayer.prepareToPlay()
        soundPlayer.volume = 2.0
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        PlayBTN.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        RecordBTN.isEnabled = true
        PlayBTN.setTitle("Play", for: .normal)
    }
    
    @IBAction func play(_ sender: AnyObject) {
        recognizeFile(url: getRecordURL())
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
                self.res = "Speech in the file is \(result.bestTranscription.formattedString)"
                print (self.res)
                self.label1.text = self.res
            }
        }
        
        return
    }

    @IBAction func recognize(_ sender: Any) {
        recognizeFile(url: getAudioURL())
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
    
}

