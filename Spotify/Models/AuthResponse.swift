//
//  AuthResponse.swift
//  Spotify
//
//  Created by Dhrumil Malaviya on 2021-03-03.
//

import Foundation


struct AuthResponse : Codable // used to save response from json data
{
    let access_token : String
    let expires_in : Int
    let refresh_token : String?
    let scope:String
    let token_type:String
}
