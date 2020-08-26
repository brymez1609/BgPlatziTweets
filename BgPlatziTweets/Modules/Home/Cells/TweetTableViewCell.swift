//
//  TweetTableViewCell.swift
//  BgPlatziTweets
//
//  Created by Bryan Andres Gomez Hernandez on 8/25/20.
//  Copyright © 2020 Bryan Andres Gomez Hernandez. All rights reserved.
//

import UIKit
import Kingfisher

class TweetTableViewCell: UITableViewCell {
    // MARK: IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //LAS CELDAS NUNCA DEBEN INVOCAR VIEW CONTROLLERS
    }
    @IBAction func openVideoAction() {
        guard let video_url = videoUrl else {
            return
        }
        needsToShowVideo?(video_url)
    }
    // MARK: - Properties
    private var videoUrl: URL?
    var needsToShowVideo: ((_ url: URL) -> Void)?
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCellWith(post: Post){
        videoButton.isHidden = !post.hasVideo
        nameLabel.text = post.author.names
        nicknameLabel.text = post.author.nickname
        messageLabel.text = post.text
        dateLabel.text = post.createdAt
        if post.hasImage {
            tweetImageView.isHidden = false
            tweetImageView.kf.setImage(with: URL(string: post.imageUrl))
        } else {
            tweetImageView.isHidden = true
        }
        videoUrl = URL(string: post.videoUrl)
    }
    
}
