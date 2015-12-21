//
//  SKTAudio.swift
//  MonkeyJump
//
//  Created by philippe eggel on 21/12/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import AVFoundation

class MonkeyAudio {
    
    // MARK: - class constants
    static let sharedInstance = MonkeyAudio()
    
    // MARK: - public properties
    var backgroundMusicPlaying: Bool {
        return backgroundMusicPlayer?.playing ?? false
    }
    
    // MARK: - private properties
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayer: AVAudioPlayer?
        
    
    func playBackgroundMusic(filename: String) {
     
        let backgroundMusicURL = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: backgroundMusicURL!)
            backgroundMusicPlayer?.numberOfLoops = -1
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch let error as NSError {
            print("AVAudioPlayer backgroundMusicPlayer init error: \(error.localizedDescription)")
        }
        
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    func playSoundEffect(filename: String) {
        let soundEffectURL = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOfURL: soundEffectURL!)
            soundEffectPlayer?.numberOfLoops = 0
            soundEffectPlayer?.prepareToPlay()
            soundEffectPlayer?.play()
        } catch let error as NSError {
            print("AVAudioPlayer soundEffectPlayer init error: \(error.localizedDescription)")
        }
    }
    
}