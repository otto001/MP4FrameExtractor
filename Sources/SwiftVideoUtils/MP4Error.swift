//
//  MP4Error.swift
//
//
//  Created by Matteo Ludwig on 22.11.23.
//

import Foundation


public enum MP4Error: Error {
    case failedToFindBox(path: String)
    case malformedBox(description: String)
    
    case noVideoTrack
    case noDataProvided
    case failedToCreateCGImage
    
    case internalError(String)
    
    case stringEncodingError
}