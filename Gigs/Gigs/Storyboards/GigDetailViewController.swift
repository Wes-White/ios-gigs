//
//  GigDetailViewController.swift
//  Gigs
//
//  Created by Wesley Ryan on 4/8/20.
//  Copyright © 2020 Wesley Ryan. All rights reserved.
//

import UIKit

class GigDetailViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dueDateDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var apiController = APIController()
    var gig: Gig?
    let dateFormatter = DateFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        //do we have title
        guard let title = titleTextField.text,
            !title.isEmpty else { return }
        //description?
        guard let description = descriptionTextView.text,
            !descriptionTextView.text.isEmpty else { return }
        
        let newGig = Gig(title: title, description: description, dueDate: "2020-04-09T05:29:01Z")
        apiController.postGig(with: newGig) { (result) in
            
            do {
                let gig = try result.get()
                self.apiController.gigs.append(gig)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
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
                        NSLog("Unexpected status code error when posting new gig\(error)")
                    case .decodingError:
                        NSLog("Error decoding the newly created Gig: \(error)")
                    case .encodingError:
                        NSLog("Error encoding the returned data: \(error)")
                    }
                }
            }
        }
    }
    
    
    
    
    func updateViews() {
        if let gig = gig {
            titleTextField.text = gig.title
            descriptionTextView.text = gig.description
            
        }
    }
}
