//
//  HttpClient.swift
//  MonkeyJump
//
//  Created by philippe eggel on 12/01/2016.
//  Copyright © 2016 PhilEagleDev.com. All rights reserved.
//

import Foundation

typealias GameTrackRecordGetServerResponse = (response: GameTrackRecord?, error: NSError?) -> ()
typealias GameTrackRecordPostServerResponse = (error: NSError?) -> ()

class HttpClient {
    static let sharedInstance = HttpClient()
    
    private static let baseURL = "http://www.phileagledev.com"
    private static let jumpArrayKey = "JumpArray"
    private static let hitArrayKey = "HitArray"
    private static let randomSeedKey = "RandomSeed"
    
    func getGameTrackRecordDetailsForKey(key: UInt64,
        completionHandler completion: GameTrackRecordGetServerResponse) {
            
            let challengeURL = NSURL(string: "\(HttpClient.baseURL)?challengeId=\(key)")!
            let request = NSURLRequest(URL: challengeURL)

            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                
                if error != nil {
                    completion(response: nil, error: error)
                }
                else if let data = data {
                    do {
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        
                        if let
                            gameTrackRecordJSON = jsonData as? NSDictionary,
                            jumpArray = gameTrackRecordJSON[HttpClient.jumpArrayKey] as? [NSTimeInterval],
                            hitArray = gameTrackRecordJSON[HttpClient.hitArrayKey] as? [NSTimeInterval],
                            randomSeedString = gameTrackRecordJSON[HttpClient.randomSeedKey] as? String,
                            randomSeed = UInt32(randomSeedString) {
                                
                                let gameTrackRecord = GameTrackRecord()
                                gameTrackRecord.jumpTimingSinceStartOfGame = jumpArray
                                gameTrackRecord.hitTimingSinceStartOfGame = hitArray
                                gameTrackRecord.randomSeed = randomSeed
                                
                                completion(response: gameTrackRecord, error: nil)
                        }
                        else {
                            throw NSError(domain: "com.phileagledev.MonkeyJump", code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Malformed JSON GameTrackRecord file."])
                        }
                        
                    } catch let error as NSError {
                        completion(response: nil, error: error)
                    }
                    
                }
                
            }
            
            task.resume()
            
    }
    
    func postGameTrackRecordDetails(gameTrackRecord: GameTrackRecord, challengeID: UInt64,
        completionHandler completion: GameTrackRecordPostServerResponse) {
            
            let params = [
                HttpClient.randomSeedKey: String(gameTrackRecord.randomSeed),
                HttpClient.jumpArrayKey: gameTrackRecord.jumpTimingSinceStartOfGame,
                HttpClient.hitArrayKey: gameTrackRecord.hitTimingSinceStartOfGame
            ]
            
            let challengeURL = NSURL(string: "\(HttpClient.baseURL)?challengeId=\(challengeID)")!
            let request = NSMutableURLRequest(
                URL: challengeURL,
                cachePolicy: .ReloadIgnoringLocalCacheData,
                timeoutInterval: 60)
            request.addValue("application/json", forHTTPHeaderField: "content-type")
            request.addValue("application/json", forHTTPHeaderField: "accept")
            request.HTTPMethod = "POST"
            
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: [])
                request.HTTPBody = jsonData
                let session = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                    (data, response, error) -> Void in
                        completion(error: error)
                }
                session.resume()
            } catch let error as NSError {
                completion(error: error)
            }
    }
}
