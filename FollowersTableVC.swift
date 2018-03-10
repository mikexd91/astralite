//
//  followersTableVC.swift
//  astralite
//
//  Created by Mike Zhang Xunda on 10/3/18.
//  Copyright © 2018 Mike Zhang Xunda. All rights reserved.
//

import UIKit
import Parse

var category = String()
var user = String()

class FollowersTableVC: UITableViewController {

    // arrays to hold data received from servers
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    //array showing who do we follow or who followings me
    var followArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = category.uppercased()
        
        loadFollowData(followCategory: category)
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func loadFollowData(followCategory: String){
        var oppoFollow = String()
        if followCategory == "follower"{
            oppoFollow = "following"
        }else{
            oppoFollow = "follower"
        }
        // Step 1: find in Follow class, people following user
        // find followers of user
        let followQuery = PFQuery(className: "Follow")
        followQuery.whereKey(oppoFollow, equalTo: user)
        followQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
                // clean up
                self.followArray.removeAll(keepingCapacity: false)
                //Step 2: hold received users
                // find related objects depending on query settings
                for object in objects!{
                    self.followArray.append(object.value(forKey: followCategory) as! String)
                }
                // Step 3: find in User class data of users following "users"
                // find users following user
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        // clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        
                        // find related objects in User class of Parse
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey:"username") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }else{
                print(error!.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // cell number
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }

    // cell configuration
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FollowersCell
        
        // connect data from server to objects
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        
        // show do user follow back or not
        let query = PFQuery(className: "Follow")
        query.whereKey("follower", equalTo: PFUser.current()!.username!)
        query.whereKey("following", equalTo: cell.usernameLbl.text!)
        query.countObjectsInBackground { (count, error) in
            if error == nil {
                if count == 0 {
                    cell.followBtn.setTitle("Follow", for: UIControlState.normal)
                    cell.followBtn.backgroundColor = UIColor.init(red: 0.135, green: 0.55, blue: 0.996, alpha: 1)
                    cell.followBtn.setTitleColor(.white, for: UIControlState.normal)
                    cell.followBtn.borderWidth = 2
                    cell.followBtn.cornerRadius = 5
                }else{
                    cell.followBtn.setTitle("Following", for: UIControlState.normal)
                    cell.followBtn.backgroundColor = UIColor.white
                    cell.followBtn.borderColor = .gray
                    cell.followBtn.setTitleColor(.black, for: UIControlState.normal)
                    cell.followBtn.borderWidth = 2
                    cell.followBtn.cornerRadius = 5
                }
                
            }
        }
        
        // hide follow button for current user
        if cell.usernameLbl.text == PFUser.current()?.username{
            cell.followBtn.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // recall cell to call further cell's data
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        // if user tapped on himself. go home else go guest
        if cell.usernameLbl.text! == PFUser.current()!.username!{
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        }else{
            guestName.append(cell.usernameLbl.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
