//
//  HomeVC.swift
//  astralite
//
//  Created by Mike Zhang Xunda on 9/3/18.
//  Copyright © 2018 Mike Zhang Xunda. All rights reserved.
//

import UIKit
import Parse

class HomeVC: UICollectionViewController {
    
    //refresher variable
    var refresher: UIRefreshControl!
    
    // size of pagingation
    var page: Int = 10
    
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        self.navigationItem.title = PFUser.current()?.username?.uppercased()
        
        // always vertical scroll
        self.collectionView?.alwaysBounceVertical = true
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(HomeVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        // load posts func
        loadPosts()
    }
    
    @IBAction func logout(_ sender: Any) {
        PFUser.logOutInBackground { (error) in
            if error == nil {
                // delete the userdefaults info
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.synchronize()
                let signin = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC" )
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = signin
            }
        }
    }
    @objc func refresh(){
        // reload data information
        collectionView?.reloadData()
        
        // stop animating
        refresher.endRefreshing()
    }
    
    func loadPosts(){
        let query  = PFQuery(className: "Posts")
        query.whereKey("username", equalTo: PFUser.current()!.username!)
        query.limit = page
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                // clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                // find objects related to our request
                for object in objects! {
                    // add found data to arrays (holders)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic")as! PFFile)
                }
                self.collectionView?.reloadData()
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count * 20
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        // get picture from array
        // indexPath.row
        picArray[0].getDataInBackground { (data, error) in
            if error == nil{
                cell.picImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // define header
        let header =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        // Step 1: get user data
        // get users data with connections to columns of PFUser class
        header.usernameLbl.text = PFUser.current()?.object(forKey: "username") as? String
        header.bioLbl.text = PFUser.current()?.object(forKey: "bio") as? String
        header.bioLbl.sizeToFit()
        header.editProfileBtn.setTitle("Edit Profile", for: UIControlState.normal)
        
        let avaQuery = PFUser.current()?.object(forKey: "ava") as? PFFile
        avaQuery?.getDataInBackground(block: { (data, error) in
            header.avaImg.image = UIImage(data: data!)
            header.avaImg.layer.cornerRadius = header.avaImg.frame.size.width/2
            header.avaImg.clipsToBounds = true
        })
        
        // Step 2: count stats
        // count total posts
        let posts = PFQuery(className: "Posts")
        posts.whereKey("username", equalTo: PFUser.current()!.username!)
        posts.countObjectsInBackground { (count, error) in
            if error == nil{
                header.posts.text = "\(count)"
            }
        }
        
        // count total followers
        let followers = PFQuery(className: "Follow")
        followers.whereKey("following", equalTo: PFUser.current()!.username!)
        followers.countObjectsInBackground { (count, error) in
            if error == nil {
                header.followers.text = "\(count)"
            }
        }
        
        // count total followings
        let followings = PFQuery(className: "Follow")
        followings.whereKey("follower", equalTo: PFUser.current()!.username!)
        followings.countObjectsInBackground { (count, error) in
            if error == nil{
                header.followings.text = "\(count)"
            }
        }
        
        // Step 3: implement tap gesture
        // tap posts
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(HomeVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(HomeVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(HomeVC.followingTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        return header
    }
    
    // tapped posts label
    @objc func postsTap(){
        if !picArray.isEmpty{
            let index = IndexPath(row: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    // tapped followers label
    @objc func followersTap(){
        user = (PFUser.current()?.username!)!
        category = "follower"
        
        // make reference to followersTableVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersTableVC") as! FollowersTableVC
        // present
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    // tapped following label
    @objc func followingTap(){
        user = (PFUser.current()?.username!)!
        category = "following"
        
        // make reference to followersTableVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersTableVC") as! FollowersTableVC
        // present
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    
    
    
}
