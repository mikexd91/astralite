//
//  HeaderView.swift
//  astralite
//
//  Created by Mike Zhang Xunda on 9/3/18.
//  Copyright © 2018 Mike Zhang Xunda. All rights reserved.
//

import UIKit
import Parse

class HeaderView: UICollectionReusableView {

    
    @IBOutlet weak var bioLbl: UITextView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var avaImg: UIImageView!
    
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var followings: UILabel!
    @IBOutlet weak var postLbl: UILabel!
    
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var followingsLbl: UILabel!
    
    @IBOutlet weak var editProfileBtn: UIButton!
    
    // default function
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // alignment
        let width = UIScreen.main.bounds.width
        avaImg.frame = CGRect(x: width/16, y: width/16, width: width/4, height: width/4)
        posts.frame = CGRect(x: width / 2.5, y: avaImg.frame.origin.y, width: 50, height: 30)
        followers.frame = CGRect(x: width / 1.7, y: avaImg.frame.origin.y, width: 50, height: 30)
        followings.frame = CGRect(x: width / 1.25, y: avaImg.frame.origin.y, width: 50, height: 30)
        
        postLbl.center = CGPoint(x: posts.center.x, y: posts.center.y + 20)
        followersLbl.center = CGPoint(x: followers.center.x, y: followers.center.y + 20)
        followingsLbl.center = CGPoint(x: followings.center.x, y: followings.center.y + 20)
        
        editProfileBtn.frame = CGRect(x: postLbl.frame.origin.x, y: postLbl.center.y + 20, width: width - postLbl.frame.origin.x - 10, height: 30)
        editProfileBtn.layer.cornerRadius = editProfileBtn.frame.size.width / 50
        
        usernameLbl.frame = CGRect(x: avaImg.frame.origin.x, y: avaImg.frame.origin.y + avaImg.frame.size.height, width: width - 30, height: 30)
        bioLbl.frame = CGRect(x: avaImg.frame.origin.x, y: usernameLbl.frame.origin.y + 30, width: width - 30, height: 30)
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
    }
    
    @IBAction func followBtn_clicked(_ sender: Any) {
        let title = editProfileBtn.title(for: .normal)
        
        // to follow
        if title == "Follow"{
            let object = PFObject(className: "Follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = usernameLbl.text
            object.saveInBackground(block: { (success, error) in
                if success{
                    self.editProfileBtn.setTitle("Following", for: UIControlState())
                    self.editProfileBtn.backgroundColor = UIColor.white
                    self.editProfileBtn.borderColor = .gray
                    self.editProfileBtn.borderWidth = 2
                    self.editProfileBtn.cornerRadius = 5
                    self.editProfileBtn.setTitleColor(.black, for: UIControlState())
                }else{
                    print(error!.localizedDescription)
                }
            })
            // unfollow
        }else{
            let query = PFQuery(className: "Follow")
            query.whereKey("follower", equalTo: PFUser.current()!.username!)
            query.whereKey("following", equalTo: usernameLbl.text!)
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) in
                            if success {
                                self.editProfileBtn.setTitle("Follow", for: UIControlState())
                                self.editProfileBtn.backgroundColor = UIColor.init(red: 0.135, green: 0.55, blue: 0.996, alpha: 1)
                                self.editProfileBtn.setTitleColor(.white, for: UIControlState.normal)
                                self.editProfileBtn.borderColor = UIColor.init(red: 0.135, green: 0.55, blue: 0.996, alpha: 1)
                                self.editProfileBtn.borderWidth = 2
                                self.editProfileBtn.cornerRadius = 5
                            }else{
                                print(error!.localizedDescription)
                            }
                        })
                    }
                }else{
                    print(error!.localizedDescription)
                }
            })
        }
    }
}
