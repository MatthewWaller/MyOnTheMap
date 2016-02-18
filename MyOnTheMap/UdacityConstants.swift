//
//  UdacityConstants.swift
//  MyOnTheMap
//
//  Created by Matthew Waller on 2/15/16.
//  Copyright © 2016 Matthew Waller. All rights reserved.
//

import Foundation

// MARK: - TMDBClient (Constants)

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ParseRestApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let BaseURLSecure : String = "https://www.udacity.com/api/"
        static let BaseParseURLSecure : String = "https://api.parse.com/1/classes/"
        
        //MARK: Application IDs
        static let ParseApplicationID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    }
    
    // MARK: Methods
    struct Methods {
        
        static let Session = "session"
        static let User = "users/{user_id}"
        static let StudentLocation = "StudentLocation"
        // MARK: Account
        static let Account = "account"
        static let AccountIDFavoriteMovies = "account/{id}/favorite/movies"
        static let AccountIDFavorite = "account/{id}/favorite"
        static let AccountIDWatchlistMovies = "account/{id}/watchlist/movies"
        static let AccountIDWatchlist = "account/{id}/watchlist"
        
        // MARK: Authentication
        static let AuthenticationTokenNew = "authentication/token/new"
        static let AuthenticationSessionNew = "authentication/session/new"
        
        // MARK: Search
        static let SearchMovie = "search/movie"
        
        }
    
    // MARK: URL Keys
    struct URLKeys {
        
        static let UserID = "user_id"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let UdacityLogin = "udacity"
        static let FacebookLogin = "facebook_mobile"
        
        static let MediaType = "media_type"
        static let MediaID = "media_id"
        static let Favorite = "favorite"
        static let Watchlist = "watchlist"
        
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        static let StudentInfoResults = "results"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session"
        
        // MARK: Account
        static let UserID = "id"
        
        
        // MARK: StudentInformation
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    
        
    }
    
}