//
//  GigController.swift
//  Gigs
//
//  Created by Wesley Ryan on 4/8/20.
//  Copyright © 2020 Wesley Ryan. All rights reserved.
//

import Foundation

class GigController {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    //api errors
    enum APIError: Error {
        case noDataError
        case noBearerError
        //a server error That has an Error
        case serverError(Error)
        case statusCodeError
        case decodingError
    }
    
    enum HeaderNames: String {
        case authorization = "Authorization"
        case contentType = "Content-Type"
    }
    
    
    var bearer = APIController().bearer
    
    var gigs : [Gig] = []
    
    let baseURL = URL(string: "https://lambdagigs.vapor.cloud/api")!
    lazy var getAllGigsURL = baseURL.appendingPathComponent("/gigs/")
    lazy var postGigURL = baseURL.appendingPathComponent("/gigs/")
    
    
    //create a func to get gigs- (Array of gigs for success and an error for failure.)
    func getAllGigs(completion: @escaping (Result<[Gig], APIError>) -> Void) {
        //build request
        var request = URLRequest(url: getAllGigsURL)
        //set http method
        request.httpMethod = HTTPMethod.get.rawValue
        //make sure user is authenticated
        
        //do we have a token?
        guard let bearer = bearer else {
            //result is failure, error is APIError case noBearer
            completion(.failure(.noBearerError))
            return
        }
        //set the value of the token in the HeaderField
        request.setValue("Bear: \(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
        
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
    
    func postGig()  {
        
        //append to gigs array
    }
    
}
