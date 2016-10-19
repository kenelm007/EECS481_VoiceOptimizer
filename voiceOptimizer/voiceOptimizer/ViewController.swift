//
//  ViewController.swift
//  voiceOptimizer
//
//  Created by panShengjie on 10/16/16.
//  Copyright © 2016 panShengjie. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var audioPlayer: AVAudioPlayer!
    
    var ae: AVAudioEngine!
    var player: AVAudioPlayerNode!
    var mixer: AVAudioMixerNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func play(sender: AnyObject) {
        let alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("email", ofType: "wav")!)
        print(alertSound)
        
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound)
            //audioPlayer.prepareToPlay()
            audioPlayer.play()
        }catch{
            print("error")
        }
    }
    
    @IBAction func show(sender: AnyObject) {
        let url = NSBundle.mainBundle().URLForResource("email", withExtension: "wav")
        let file = try! AVAudioFile(forReading: url!)
        let format = AVAudioFormat(commonFormat: .PCMFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
        let buf = AVAudioPCMBuffer(PCMFormat: format, frameCapacity: UInt32(file.length))
        try! file.readIntoBuffer(buf) // You probably want better error handling
        var rightArray = Array(UnsafeBufferPointer(start: buf.floatChannelData[0], count:Int(buf.frameLength)))
        
        //filter
        let sample = 10000
        let threshold = Float(0.125)
        for var i = 0; i < rightArray.count / sample; i++ {
            let first = i * sample
            let last = min((i + 1) * sample - 1, rightArray.count - 1)
            if max(rightArray[first...last].maxElement()!, -rightArray[first...last].minElement()!) < threshold {
                rightArray[first...last] = []
                i--
            }
        }
        
        let newbuf = AVAudioPCMBuffer(PCMFormat: format, frameCapacity: UInt32(rightArray.count))
        newbuf.frameLength = UInt32(rightArray.count)
        for var i = 0; i < rightArray.count; i++ {
            newbuf.floatChannelData.memory[i] = rightArray[i]
        }
        
        ae = AVAudioEngine()
        player = AVAudioPlayerNode()
        mixer = ae.mainMixerNode
        
        ae.attachNode(player)
        ae.connect(player, to: mixer, format: player.outputFormatForBus(0))
        try! ae.start()
        
        player.play()
        player.scheduleBuffer(buf, completionHandler: nil)
        player.play()
        player.scheduleBuffer(newbuf, completionHandler: nil)

    }
    
    @IBOutlet weak var text: UILabel!
}

