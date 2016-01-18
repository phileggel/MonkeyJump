//
//  ChallengesPickerViewController.swift
//  MonkeyJump
//
//  Created by philippe eggel on 18/01/2016.
//  Copyright © 2016 PhilEagleDev.com. All rights reserved.
//

import GameKit

typealias ChallengeCanceledBlock = () -> ()
typealias ChallengeSelectedBlock = (GKScoreChallenge) -> ()

class ChallengesPickerViewController: UIViewController {
    private static let challengeKey = "ChallengeKey"
    private static let playerKey = "PlayerKey"
    
    private var dataSource: [String: [String: AnyObject]]
    var challengeCanceledBlock: ChallengeCanceledBlock?
    var challengeSelectedBlock: ChallengeSelectedBlock?
    
    @IBOutlet weak var tableView: UITableView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.dataSource = [:]
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let gameKitHelper = GameKitHelper.sharedInstance
        gameKitHelper.delegate = self
        gameKitHelper.loadChallenges()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.translucent = false
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelButtonPressed:")
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let gameKitHelper = GameKitHelper.sharedInstance
        gameKitHelper.delegate = nil
    }
    
    func cancelButtonPressed(sender: UIBarButtonItem) {
        
        let gameKitHelper = GameKitHelper.sharedInstance
        gameKitHelper.delegate = nil
        if let challengeCanceledBlock = challengeCanceledBlock {
            challengeCanceledBlock()
        }
    }
}

extension ChallengesPickerViewController: GameKitHelperProtocol {
    func onChallengesReceived(challenges: [GKChallenge]) {
        
        var playerIDs: [String] = []
        
        for challenge in challenges {
            if let player = challenge.issuingPlayer, playerID = player.playerID {
                if dataSource[playerID] == nil {
                    dataSource[playerID] = [:]
                    playerIDs.append(playerID)
                }
                dataSource[playerID]![ChallengesPickerViewController.challengeKey] = challenge
            }
        }
        
        GameKitHelper.sharedInstance.loadPlayerInfo(playerIDs)
        tableView.reloadData()
    }
    
    func onPlayerInfoReceived(players: [GKPlayer]) {
        
        for player in players {
            if let playerID = player.playerID {
                if dataSource[playerID] == nil {
                    dataSource[playerID] = [:]
                }
                
                dataSource[playerID]![ChallengesPickerViewController.playerKey] = player
                tableView.reloadData()
            }
        }
    }
}

extension ChallengesPickerViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell identifier"
        let playerImageTag = 1
        let playerNameTag = 2
        let challengeTextTag = 3
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
            cell?.backgroundColor = UIColor.clearColor()
            
            let playerName = UILabel(frame: CGRect(x: 50, y: 0, width: 150, height: 44))
            playerName.tag = playerNameTag
            playerName.textColor = UIColor.whiteColor()
            playerName.font = UIFont.systemFontOfSize(18)
            playerName.backgroundColor = UIColor.clearColor()
            playerName.textAlignment = .Center
            cell?.addSubview(playerName)
            
            let playerImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            playerImage.tag = playerImageTag
            cell?.addSubview(playerImage)
            
            let challengeText = UILabel(frame: CGRect(x: 220, y: 0, width: 240, height: cell!.frame.size.height))
            challengeText.tag = challengeTextTag
            challengeText.backgroundColor = UIColor.whiteColor()
            cell?.contentView.addSubview(challengeText)
        }
        
        let challengeInfo = dataSource[Array(dataSource.keys)[indexPath.row]]
        let challenge = challengeInfo![ChallengesPickerViewController.challengeKey]
        let player = challengeInfo![ChallengesPickerViewController.playerKey]
        
        player?.loadPhotoForSize(GKPhotoSizeSmall, withCompletionHandler: { (photo, error) -> Void in
            if error == nil {
                let playerImage = cell?.viewWithTag(playerImageTag) as? UIImageView
                playerImage?.image = photo
            } else {
                print("Error loading image")
            }
        })
        
        let playerName = cell?.viewWithTag(playerNameTag) as? UILabel
        playerName?.text = player?.displayName
        
        let challengeText = cell?.viewWithTag(challengeTextTag) as? UILabel
        challengeText?.text = challenge?.message
        
        return cell!
    }
}

extension ChallengesPickerViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let challengeInfo = dataSource[Array(dataSource.keys)[indexPath.row]]
        let challenge = challengeInfo![ChallengesPickerViewController.challengeKey] as? GKScoreChallenge
        
        if let challengeSelectedBlock = challengeSelectedBlock {
            let gameKitHelper = GameKitHelper.sharedInstance
            gameKitHelper.delegate = nil
            challengeSelectedBlock(challenge!)
        }
        
    }
    
}