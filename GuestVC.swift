//
//  GuestVC.swift
//  astralite
//
//  Created by Mike Zhang Xunda on 10/3/18.
//  Copyright © 2018 Mike Zhang Xunda. All rights reserved.
//

import UIKit
import Parse

var guestName = [String]()

private let reuseIdentifier = "Cell"

class GuestVC: UICollectionViewController {

    // UI Objects
    var refresher: UIRefreshControl!
    var page: Int = 10
    
    // arrays to hold data from server
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allowes vertical scroll
        self.collectionView?.alwaysBounceVertical = true
        
        // show guest title
        self.navigationItem.title = guestName.last
        
        // background color
        self.collectionView?.backgroundColor = .white
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(GuestVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GuestVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(GuestVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        // call load posts function
        loadPosts()
    }
    
    @objc func back(_ sender: UIBarButtonItem){
        // push back
        _ = self.navigationController?.popViewController(animated: true)
        
        // clean guest username or deduct the last guest username from guestname array
        if(!guestName.isEmpty){
            guestName.removeLast()
        }
    }
    
    @objc func refresh(){
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
  
    
    func loadPosts(){
        // load posts
        let query = PFQuery(className: "Posts")
        query.whereKey("username", equalTo: guestName.last!)
        query.limit = page
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                // clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                //find related objects
                for object in objects!{
                    // hold found information in arrays
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                }
                self.collectionView?.reloadData()
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    // cell number
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    //cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // define cell
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        
        // conncet data from array to picImage object from picture cell class
        picArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        return cell
    }
    
    //header config
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //define header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        //Step 1L Load data of guest
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestName.last!)
        infoQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
                
                // show wrong user
                if objects!.isEmpty{
                    print("wrong user")
                }
                //find related to user info
                for object in objects!{
                    header.usernameLbl.text = object.object(forKey: "username") as? String
                    header.bioLbl.text = object.object(forKey: "bio") as? String
                    let avaFile = (object.object(forKey: "ava") as? PFFile)!
                    avaFile.getDataInBackground(block: { (data, error) in
                        header.avaImg.image = UIImage(data: data!)
                    })
                }
                
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
        // Step 2: show do current user follow guest or not
        let followQuery = PFQuery(className: "Follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.whereKey("following", equalTo: guestName.last!)
        followQuery.countObjectsInBackground { (count, error) in
            if error == nil {
                if count == 0{
                    header.editProfileBtn.setTitle("Follow", for: UIControlState.normal)
                    header.editProfileBtn.backgroundColor = UIColor.init(red: 0.135, green: 0.55, blue: 0.996, alpha: 1)
                   header.editProfileBtn.setTitleColor(.white, for: UIControlState.normal)
                }else{
                    header.editProfileBtn.setTitle("Following", for: UIControlState.normal)
                    header.editProfileBtn.backgroundColor = UIColor.white
                    header.editProfileBtn.borderColor = .gray
                    header.editProfileBtn.setTitleColor(.black, for: UIControlState.normal)
                }
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
        // Step 3. count statistics
        // count posts
        let posts = PFQuery(className: "Posts")
        posts.whereKey("username", equalTo: guestName.last!)
        posts.countObjectsInBackground { (count, error) in
            if error == nil {
                header.posts.text = "\(count)"
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
        // count followers
        let followers = PFQuery(className: "Follow")
        followers.whereKey("following", equalTo: guestName.last!)
        followers.countObjectsInBackground { (count, error) in
            if error == nil {
                header.followers.text = "\(count)"
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
        //count following
        let following = PFQuery(className: "Follow")
        following.whereKey("follower", equalTo: guestName.last!)
        following.countObjectsInBackground { (count, error) in
            if error == nil {
                header.followings.text = "\(count)"
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
        // Step 4. implement tap gestures
        // tap to posts label
        let postTap = UITapGestureRecognizer(target: self, action: #selector(GuestVC.postsTap))
        postTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postTap)
        
        // tap to followers
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(GuestVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        // tap to following
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(GuestVC.followingTap))
        followingTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingTap)
        
        return header
    }
    
    @objc func postsTap(){
        if !picArray.isEmpty{
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    @objc func followersTap(){
        user = guestName.last!
        category = "follower"
        
        //define followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersTableVC") as! FollowersTableVC
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    @objc func followingTap(){
        user = guestName.last!
        category = "following"
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "FollowersTableVC") as! FollowersTableVC
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    
}
