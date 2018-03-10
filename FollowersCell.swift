//
//  FollowersCell.swift
//  astralite
//
//  Created by Mike Zhang Xunda on 10/3/18.
//  Copyright © 2018 Mike Zhang Xunda. All rights reserved.
//

import UIKit
import Parse

class FollowersCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avaImg.layer.cornerRadius = avaImg.frame.size.width/2
        avaImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // follow or unfollow
    @IBAction func followBtn_click(_ sender: Any) {
        let title = followBtn.title(for: .normal)
        
        // to follow
        if title == "Follow"{
            let object = PFObject(className: "Follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = usernameLbl.text
            object.saveInBackground(block: { (success, error) in
                if success{
                    self.followBtn.setTitle("Following", for: UIControlState())
                    self.followBtn.backgroundColor = UIColor.white
                    self.followBtn.borderColor = .gray
                    self.followBtn.borderWidth = 2
                    self.followBtn.cornerRadius = 5
                    self.followBtn.setTitleColor(.black, for: UIControlState())
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
                                self.followBtn.setTitle("Follow", for: UIControlState())
                                self.followBtn.backgroundColor = UIColor.init(red: 0.135, green: 0.55, blue: 0.996, alpha: 1)
                                self.followBtn.setTitleColor(.white, for: UIControlState.normal)
                                self.followBtn.borderColor = UIColor.init(red: 0.135, green: 0.55, blue: 0.996, alpha: 1)
                                self.followBtn.borderWidth = 2
                                self.followBtn.cornerRadius = 5
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
