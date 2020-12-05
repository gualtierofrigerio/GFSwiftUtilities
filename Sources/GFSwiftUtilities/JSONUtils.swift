//
//  JSONUtils.swift
//
//  Created by Gualtiero Frigerio on 06/10/2020.
//

import Foundation

/// Utility functions for JSON conversion and interaction with the file system
public class JSONUtils {
    /// Builds a Data object from a JSON object like a dictionary or an array
    /// - Parameter fromObject: the object to encode as string
    /// - Returns: an optional Data if it was possible to encode the object as a JSON
    public class func getData(fromObject jsonObject:Any) -> Data? {
        var data:Data? = nil
        if JSONSerialization.isValidJSONObject(jsonObject) {
            data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed)
        }
        return data
    }
    
    /// Returns a JSON object from a file
    /// The function removes enconding characters from the string if present
    /// - Parameter fromPath: the file's path
    /// - Returns: an optional Any object if it was possible to decode a JSON from the file
    public class func getJSON(fromPath path:String) -> Any? {
        if let string = readString(fromPath: path) {
            return getJSON(fromString: string)
        }
        return nil
    }
    
    /// Returns a JSON object from a string
    /// The function removes enconding characters from the string if present
    /// - Parameter fromString: the string containing the JSON
    /// - Returns: an optional Any object if it was possible to decode a JSON from the string
    public class func getJSON(fromString jsonString:String) -> Any? {
        if let data = jsonString.removingPercentEncoding?.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with:data , options: .allowFragments) {
                return jsonObject
        }
        return nil
    }
    
    /// Builds a string from a JSON object like a dictionary or an array
    /// - Parameter fromObject: the object to encode as string
    /// - Returns: an optional string if it was possible to encode the object as a JSON string
    public class func getString(fromObject jsonObject:Any) -> String? {
        if let data = JSONUtils.getData(fromObject: jsonObject),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }
    
    /// Reads a file and returns a string with its content
    /// - Parameter fromPath: the file's path
    /// - Returns: an optional string if it was possible to read the file into a String
    public class func readString(fromPath path:String) -> String? {
        let url = URL(fileURLWithPath: path)
        let fileString = try? String(contentsOf: url)
        return fileString
    }
    
    /// Write a JSON object to file
    /// - Parameters:
    ///   - object: JSON object to write
    ///   - path: path of the file to be written
    /// - Throws:
    public class func writeJSON(object:Any, toPath path:String) throws {
        guard let data = getData(fromObject: object) else {return}
        let url = URL(fileURLWithPath: path)
        try data.write(to: url)
    }
    
    /// Write a string on a file at a given path
    /// - Parameter path: The path of the file to be written
    /// - Throws:
    public class func writeString(string:String, toPath path:String) throws {
        let url = URL(fileURLWithPath: path)
        try string.write(to: url, atomically: true, encoding: .utf8)
    }
}
