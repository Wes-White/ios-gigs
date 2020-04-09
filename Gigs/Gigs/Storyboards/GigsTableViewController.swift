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
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
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
                    case .encodingError:
                        NSLog("Error encoding the returned data: \(error)")
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
        cell.detailTextLabel?.text = apiController.gigs[indexPath.row].dueDate

     

        return cell
    }
  

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
            if segue.identifier == "GigDetailViewSegue" {
                guard let ShowGigVC = segue.destination as? GigDetailViewController else {
                    return
                }
                
                guard let selected = tableView.indexPathForSelectedRow else { return }
                
                ShowGigVC.gig = apiController.gigs[selected.row]
            } else if segue.identifier == "AddGigSegue" {
                guard let ShowNewGigVC = segue.destination as? GigDetailViewController else {
                    return
                }
                
                ShowNewGigVC.apiController = apiController
            }
        }
    }
