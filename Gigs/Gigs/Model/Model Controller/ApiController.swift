//
//  ApiController.swift
//  Gigs
//
//  Created by Wesley Ryan on 4/7/20.
//  Copyright © 2020 Wesley Ryan. All rights reserved.
//

import Foundation


class APIController {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    //api errors
    enum APIError: Error {
        case noDataError
        case noBearerError
        //a server error That has an Error
        case serverError(Error)
        case statusCodeError
        case decodingError
        case encodingError
    }
    
    enum HeaderNames: String {
        case auth = "Authorization"
        case contentType = "Content-Type"
    }
    
    let baseURL = URL(string: "https://lambdagigs.vapor.cloud/api")!
    private lazy var signUpRequestURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var loginURL = baseURL.appendingPathComponent("/users/login")
    private lazy var getAllGigsURL = baseURL.appendingPathComponent("gigs")
    private lazy var postGigURL = baseURL.appendingPathComponent("gigs")
    
    
    
    var bearer: Bearer?
    var gigs: [Gig] = []
    
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
                
                completion(APIError.statusCodeError)
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
                completion(APIError.statusCodeError)
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                //decode token and set to bearer
                self.bearer = try decoder.decode(Bearer.self, from: data)
                
                //Save the token with UserDefaults
                UserDefaults.standard.set(self.bearer?.token, forKey: "token")
                completion(nil)
                print("AFTER LOGIN: \(self.bearer!)")
            } catch {
                NSLog("Error decoding the token: \(error)")
                completion(error)
            }
            
            completion(nil)
        } .resume()
    }
    
    
    //create a func to get gigs- (Array of gigs for success and an error for failure.)
    func getAllGigs(completion: @escaping (Result<[Gig], APIError>) -> Void) {
        
        //do we have a token? checking from userDefaults

        guard let token = UserDefaults.standard.value(forKey: "token")  else {
            //result is failure, error is APIError case noBearer
            completion(.failure(.noBearerError))
            return
        }
        
        //build request
        var request = URLRequest(url: getAllGigsURL)
        //set http method
        request.httpMethod = HTTPMethod.get.rawValue
        //set the value of the token in the HeaderField
        request.setValue("Bearer \(token)", forHTTPHeaderField: HeaderNames.auth.rawValue)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                //Result is failed, error is the APIError that takes the error we recieve
                NSLog("Error from server: \(error)")
                completion(.failure(.serverError(error)))
                return
            }
            // check the status code we recieved from the server
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.statusCodeError))
            }
            //make sure we have data being returned
            guard let data = data else {
                completion(.failure(.noDataError))
                return
            }
            
            do {
                //decode the data we get returned.
                let gigNames = try JSONDecoder().decode([Gig].self, from: data)
                
                self.gigs.append(contentsOf: gigNames)
                //result type is success gigNames should be our decoded array of Gig.
                completion(.success(gigNames))
            } catch {
                NSLog("Error decoding the returned data: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    
    
    //create a func to post a new gig
    
    func postGig(with gig: Gig, completion: @escaping (Result<Gig, APIError>) -> Void) {
        //do we have a token? checking from userDefaults
        guard let token = UserDefaults.standard.value(forKey: "token")  else {
        //result is failure, error is APIError case noBearer
        completion(.failure(.noBearerError))
        return
        }
        
        var request = URLRequest(url: postGigURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: HeaderNames.contentType.rawValue)
        request.setValue("token", forHTTPHeaderField: HeaderNames.auth.rawValue)
        
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(gig)
            
        } catch {
            completion(.failure(.encodingError))
        }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.serverError(error)))
                NSLog("Error from the server: \(error)")
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.statusCodeError))
               
            }
            
            guard let data = data else {
                completion(.failure(.noDataError))
                return
            }
            let decoder = JSONDecoder()
            
            do {
                let gig = try decoder.decode(Gig.self, from: data)
                completion(.success(gig))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
