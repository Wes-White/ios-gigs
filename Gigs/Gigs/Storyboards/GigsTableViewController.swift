//
//  GigsTableViewController.swift
//  Gigs
//
//  Created by Wesley Ryan on 4/7/20.
//  Copyright © 2020 Wesley Ryan. All rights reserved.
//

import UIKit

class GigsTableViewController: UITableViewController {

    let apiController = APIController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if apiController.bearer == nil {
            performSegue(withIdentifier: "LoginSegue", sender: self)
            }
        
       updateGigs()
            
        }

    
     func updateGigs() {
        apiController.getAllGigs { (result) in
            do {
                //get the value from our result
                let gigs = try result.get()
                //pass the value into our gigs array
                self.apiController.gigs = gigs
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                
                if let error = error as? APIController.APIError {
                    switch error {
                    case .noDataError:
                        NSLog("There was an error retrieving the data: \(error)")
                    case .noBearerError:
                        NSLog("There was an error validating your token: \(error)")
                    case .serverError(_):
                        NSLog("There was an error on the server: \(error)")
                    case .statusCodeError:
                        NSLog("Unexpected status code errro \(error)")
                    case .decodingError:
                        NSLog("Error decoding the returned data: \(error)")
                    }
                }
            }
        }
    }
        
 


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return apiController.gigs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GigsTableViewControllerCell", for: indexPath)
        
        cell.textLabel?.text = apiController.gigs[indexPath.row].title
        cell.detailTextLabel?.text = "Due date:"

     

        return cell
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    /*
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginSegue" {
            if let loginVC = segue.destination as? LoginViewController {
               
            }
        }
    }
 */
    

}
