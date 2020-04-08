//
//  ApiController.swift
//  Gigs
//
//  Created by Wesley Ryan on 4/7/20.
//  Copyright © 2020 Wesley Ryan. All rights reserved.
//

import Foundation
import  UIKit

class APIController {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    
    private let baseURL = URL(string: "https://lambdagigapi.herokuapp.com/api")!
    private lazy var signUpRequestURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var loginURL = baseURL.appendingPathComponent("/users/login")
    
    var bearer: Bearer?
    
    
    //create func for sign up
    
    func signUp(with user: User, completion: @escaping (Error?) -> Void) {
        // Build a request
        
        var request = URLRequest(url: signUpRequestURL)
        //We want to do a post request
        request.httpMethod = HTTPMethod.post.rawValue
        //Tell API we are working with JSON
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //turn user into JSON so we can attach it to the request.
        let encoder = JSONEncoder()
        
        do {
            let userJSON = try encoder.encode(user)
            request.httpBody = userJSON
        } catch {
            NSLog("There was an error encoding the User Object: \(error)")
        }
        
        // Perform the request (data task)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Handle Errors with the request.
            if let error = error {
                NSLog("Error performing signUP : \(error)")
                completion(error)
            }
            // cast response as HTTPURLResponse
            if let response = response as? HTTPURLResponse,
                //if response status is not 200...
                response.statusCode != 200 {
                //Creating the error to check response status
                let statusCodeError = NSError(domain: "com.WesleyWhite.Gigs", code: response.statusCode, userInfo: nil)
                completion(statusCodeError)
            }
            //nil means there was no error, we are groovy.
            completion(nil)
            //start data task
        } .resume()
    }
    // create func for login
    
    func login(with user: User, completion: @escaping (Error?) -> Void)  {
        
        var request = URLRequest(url: loginURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        
        do {
            let userJson = try encoder.encode(user)
            request.httpBody = userJson
        } catch {
            NSLog("There was an error encoding the login data: \(error)")
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("There was an error logging in: \(error)")
                completion(error)
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                let noDataError = NSError(domain: "com.WesleyWhite.Gigs", code: -1 , userInfo: nil)
                completion(noDataError)
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                //decode token and set to bearer
                self.bearer = try decoder.decode(Bearer.self, from: data)
                completion(nil)
                print(self.bearer)
            } catch {
                NSLog("Error decoding the token: \(error)")
                completion(error)
            }
            
            completion(nil)
        } .resume()
    }
    
    // create func for fetching gigs
    
    // create func for fetching images
}
