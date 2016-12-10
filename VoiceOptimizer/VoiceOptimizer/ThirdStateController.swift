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
import Contacts

class ThirdStateController: UIViewController {
    
    @IBOutlet weak var rec_text: UITextView!
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var audioname = "audiofile.wav"
    var filename = "record.m4a"
    var text : String = ""
    let url_schema = [
        "photos": "photos-redirect://",
        "news": "applenews:",
        "videos":  "Videos:",
        //"brightness":  "launch://brightness/",
        //"remote": "remote://",
        "phone":  "launch://dial/",
        "calendar":  "calshow:",
        //"flashlight":  "launch://light",
        "mail":  "message://",
        "find my iphone":  "fmip1:",
        "podcasts":  "pcast:",
        "ibooks":  "ibooks:",
        "music": "music:",
        "facebook": "fb://",
        "youtube": "youtube://",
        //"messenger":,
        //"amazon":"amazon://",
        "map": "comgooglemaps://",
        "safari": "https://www.google.com",
        "twitter": "twitter://",
        "instagram": "instagram://",
        //"timer": "clock-timer://",
        //"alarm clock": "clock-alarm://",
        //"world clock": "clock-worldclock://",
        //"stopwatch": "clock-stopwatch://"
    ]
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
        self.rec_text.isEditable = false
        optimize(url: getRecordURL())
        prepareNewPlayer(url: getAudioURL())
        recognizeFile(url: getAudioURL())
        
        
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
    
    // Mark: Action
    @IBAction func recordAnother(_ sender: UIButton) {
        print("record another")
        stopAudio()
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
    
    func prepareNewPlayer(url: URL){
        do {
            try soundPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            assert(false, "Fail to initial sound player")
        }
        soundPlayer.prepareToPlay()
        soundPlayer.volume = 0.8
        soundPlayer.enableRate = true
        soundPlayer.rate = 1.2
    }
    
    func prepareOldPlayer(url: URL){
        do {
            try soundPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            assert(false, "Fail to initial sound player")
        }
        soundPlayer.prepareToPlay()
        soundPlayer.volume = 0.8
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
                self.text = "Fail to recognize the audio"
                print (self.text)
                self.rec_text.text = self.text
                return
            }
            if result.isFinal {
                self.text = "\(result.bestTranscription.formattedString)"
                print (self.text)
                self.rec_text.text = self.text
                self.pre_proccess(command: self.text)
                
                
            }
        }
        
        return
    }
    
    func pre_proccess(command: String){
        let index = command.index(command.startIndex, offsetBy:4)
        if command.substring(to: index).lowercased() == "open"{
            let index_sub = command.index(command.startIndex, offsetBy: 5)
            let instruction = command.substring(from: index_sub).lowercased()
            print (instruction)
            if url_schema[instruction] != nil
            {
                proccess(url: url_schema[instruction]!)
            }
            else {
                print ("ERROR Command not found mei you")
            }
            
        }
        else{
            if command.substring(to: index).lowercased() == "call"{
                let index_sub = command.index(command.startIndex, offsetBy: 5)
                let number = command.substring(from: index_sub).lowercased()
                var isNumber = true
                print (number)
                let digits = CharacterSet.decimalDigits
                for ch in number.unicodeScalars{
                    if !digits.contains(ch){
                        if ch == "-" {
                            continue
                        }
                        isNumber = false
                    }
                }
                if (isNumber) {
                    call(number: number)
                } else {
                    let phoneNumber = findContactByName(name: number)
                    if (phoneNumber != "") {
                        call(number: phoneNumber)
                    }
                }
            }
        }
        
        
        
    }
    
    func findContactByName(name: String) -> String {
        let store = CNContactStore()
        var phone = ""
        let keysToFectch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keysToFectch as [CNKeyDescriptor])
        
        do {
            try store.enumerateContacts(with: request) {
                (contact, stop) in
                let givenName = contact.givenName.lowercased()
                let fullName = contact.givenName.lowercased() + " " + contact.familyName.lowercased()
                if (givenName == name || fullName == name) {
                    print (fullName)
                    let phoneNumberStruct = contact.phoneNumbers[0].value as CNPhoneNumber
                    for ch in phoneNumberStruct.stringValue.characters {
                        if (ch >= "0" && ch <= "9") {
                            phone = phone + String(ch)
                        }
                    }
                    return
                    
                }
            }
        }
        catch {
            print ("unable to fetch contacts")
        }
        return phone
    }
    
    func call(number: String){
        var appHooks = "tel://" + number;
        var appUrl = NSURL(string: appHooks)
        if UIApplication.shared.canOpenURL(appUrl! as URL)
        {
            UIApplication.shared.openURL(appUrl! as URL)
            
        } else {
            //UIApplication.shared.openURL(NSURL(string: "http://instagram.com/")! as URL)
            print("NO APPLICATION SUPPORT")
        }

    }
    func proccess(url: String){
        var appHooks = url
        var appUrl = NSURL(string: appHooks)
        if UIApplication.shared.canOpenURL(appUrl! as URL)
        {
            UIApplication.shared.openURL(appUrl! as URL)
            
        } else {
            //UIApplication.shared.openURL(NSURL(string: "http://instagram.com/")! as URL)
            print("NO APPLICATION SUPPORT")
        }

    }
    @IBAction func playvoice(_ sender: Any) {
        prepareNewPlayer(url: getAudioURL())
        print("play voice!")
        soundPlayer.play()

    }
    
    func filter(array: Array<Float>) -> Array<Float> {
        var newRightArray = array.sorted{ abs($0) < abs($1) }
        let threshold = abs(newRightArray[Int(Float(newRightArray.count) * 0.62)])
        let sample = 300
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
    
    func getTestURL(filename: String) -> URL{
        let url = Bundle.main.url(forResource: filename, withExtension: "wav")
        return url!;
    }
    
    @IBAction func playOriginal(_ sender: UIButton) {
        prepareOldPlayer(url: getRecordURL())
        soundPlayer.play()
    }
    
//    @IBAction func playTest1(_ sender: Any) {
//        preparePlayer(url: getTestURL(filename: "test1"))
//        soundPlayer.play()
//    }
//    
//    @IBAction func recognizeTest1(_ sender: Any) {
//        optimize(url: getTestURL(filename: "test1"))
//        recognizeFile(url: getAudioURL())
//    }
//    
//    @IBAction func playTest2(_ sender: Any) {
//        preparePlayer(url: getTestURL(filename: "test2"))
//        soundPlayer.play()
//    }
//    
//    @IBAction func recognizeTest2(_ sender: Any) {
//        optimize(url: getTestURL(filename: "test2"))
//        recognizeFile(url: getAudioURL())
//    }
//    
//    @IBAction func playTest3(_ sender: Any) {
//        preparePlayer(url: getTestURL(filename: "test3"))
//        soundPlayer.play()
//    }
//    
//    @IBAction func recognizeTest3(_ sender: Any) {
//        optimize(url: getTestURL(filename: "test3"))
//        recognizeFile(url: getAudioURL())
//    }
    
    @IBAction func stop(_ sender: Any) {
        stopAudio()
    }
    
    func stopAudio(){
        if (soundPlayer.isPlaying) {
            soundPlayer.stop()
        }
    }
}
