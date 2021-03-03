//
//  AuthManager.swift
//  Spotify
//
//  Created by Dhrumil Malaviya on 2021-03-01.
//

import Foundation

final class AuthManager
{
    static let shared = AuthManager() //singleton class
    
    struct Constants
    {
        static let clientID = "717f211057574fadb9cb4da9fc5e5865"
        static let clientSecret = "62b7cec932f147c69f500cb51dba147c"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://google.com"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    public var signInUrl:URL?
    {
        let base = "https://accounts.spotify.com/authorize"
        let url = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string:url)
        
    }
    
    private init()
    {
        
    }
    
    var isSignedIn:Bool
    {
        return accessToken != nil
    }
    
    private var accessToken: String?
    {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String?
    {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate:Date?
    {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool
    {
        guard let expirationDate = tokenExpirationDate else {return false}
        
        let currentDate = Date()
        let fiveMinutes:TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func refreshIfNeeded(completion:@escaping (Bool)->Void)
    {
        guard shouldRefreshToken
        else
        { completion(true)
            return
        }
        guard let refreshToken =  self.refreshToken else
        {
            return}
        //Refresh the token
            
            guard let url = URL(string: Constants.tokenAPIURL) else {
                return
            }
            
            var components = URLComponents()
            components.queryItems = [
                URLQueryItem(name: "grant_type", value: "refresh_token"),
                URLQueryItem(name: "refresh_token", value: refreshToken),
            ]
            var request = URLRequest(url: url)
            request.httpMethod="POST"
            request.setValue("application/x-www-form-urlencoded ", forHTTPHeaderField: "Content-Type")
            request.httpBody = components.query?.data(using:.utf8)
            
            let basicToken = Constants.clientID+":"+Constants.clientSecret
            let data = basicToken.data(using: .utf8)
            guard let base64String = data?.base64EncodedString() else
            {
                print("Failure to get base 64")
                completion(false)
                return
            }
            
            request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization") //header
            
            let task = URLSession.shared.dataTask(with: request) { [weak self]data, _, error in
                guard let data = data,
                      error == nil else
                {
                    completion(false)
                    return
                }
                do {
                    let results = try JSONDecoder().decode(AuthResponse.self, from: data) //if modal class is created then use this method
                    
                    print("Successfully refreshed")
                    self?.cacheToken(result:results)
                    
                    
                    //let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)// if data is to be fetched from object itself then use jsonSerialization
                    completion(true)
                    
                    
                }
                catch
                {
                    print(error.localizedDescription)
                    completion(false)
                }
            }
            task.resume()
        }

            

        
    
    public func exchangeCodeForToken(code:String, completion: @escaping ((Bool)->Void))
    {
        
        //GET TOKEN
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: "https://google.com"),
        ]
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.setValue("application/x-www-form-urlencoded ", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using:.utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else
        {
            print("Failure to get base 64")
            completion(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization") //header
        
        let task = URLSession.shared.dataTask(with: request) { [weak self]data, _, error in
            guard let data = data,
                  error == nil else
            {
                completion(false)
                return
                
            }
            do {
                let results = try JSONDecoder().decode(AuthResponse.self, from: data) //if modal class is created then use this method
                self?.cacheToken(result:results)
                
                
                //let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)// if data is to be fetched from object itself then use jsonSerialization
                completion(true)
                
                
            }
            catch
            {
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
    
    private func cacheToken(result:AuthResponse)
    {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refreshToken = result.refresh_token{
            UserDefaults.standard.setValue(refreshToken, forKey: "refresh_token")}
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)) , forKey: "expirationDate")
    }
}
