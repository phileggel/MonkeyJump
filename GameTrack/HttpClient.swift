//
//  HttpClient.swift
//  MonkeyJump
//
//  Created by philippe eggel on 12/01/2016.
//  Copyright © 2016 PhilEagleDev.com. All rights reserved.
//

import Foundation

typealias GameTrackingGetServerResponse = (response: GameTracking?, error: NSError?) -> ()
typealias GameTrackingPostServerResponse = (error: NSError?) -> ()

class HttpClient {
    static let sharedInstance = HttpClient()
    
    private static let baseURL = "http://www.phileagledev.com"
    private static let jumpArrayKey = "JumpArray"
    private static let hitArrayKey = "HitArray"
    private static let randomSeedKey = "RandomSeed"
    
    func getGameTrackingDetailsForKey(key: UInt64,
        completionHandler completion: GameTrackingGetServerResponse) {
            
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
                            gameTrackingJSON = jsonData as? NSDictionary,
                            jumpArray = gameTrackingJSON[HttpClient.jumpArrayKey] as? [NSTimeInterval],
                            hitArray = gameTrackingJSON[HttpClient.hitArrayKey] as? [NSTimeInterval],
                            randomSeedString = gameTrackingJSON[HttpClient.randomSeedKey] as? String,
                            randomSeed = UInt32(randomSeedString) {
                                
                                let gameTracking = GameTracking()
                                gameTracking.jumpTimingSinceStartOfGame = jumpArray
                                gameTracking.hitTimingSinceStartOfGame = hitArray
                                gameTracking.randomSeed = randomSeed
                                
                                completion(response: gameTracking, error: nil)
                        }
                        else {
                            throw NSError(domain: "com.phileagledev.MonkeyJump", code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Malformed JSON GameTracking file."])
                        }
                        
                    } catch let error as NSError {
                        completion(response: nil, error: error)
                    }
                    
                }
                
            }
            
            task.resume()
            
    }
    
    func postGameTrackingDetails(gameTracking: GameTracking, challengeID: Int,
        completionHandler completion: GameTrackingPostServerResponse) {
            
            let params = [
                HttpClient.randomSeedKey: String(gameTracking.randomSeed),
                HttpClient.jumpArrayKey: gameTracking.jumpTimingSinceStartOfGame,
                HttpClient.hitArrayKey: gameTracking.hitTimingSinceStartOfGame
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
