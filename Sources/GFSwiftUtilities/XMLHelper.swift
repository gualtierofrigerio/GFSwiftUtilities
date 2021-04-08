//
//  XMLHelper.swift
//  GFSwiftUtilities
//
//  Created by Gualtiero Frigerio on 27/03/21.
//

import Foundation
import Combine

struct XMLElement {
    var value:String
    var attributes:[String:String]
}

typealias XMLDictionary = [String:Any]

class XMLHelper:NSObject {
    func parseXML(atURL url:URL,
                  completion:@escaping (XMLDictionary?) -> Void) {
        guard let data = try? Data(contentsOf: url) else {
            completion(nil)
            return
        }
        parseXML(data: data, completion: completion)
    }
    
    func parseXML(atURL url:URL,
                  elementName:String,
                  completion:@escaping (Array<XMLDictionary>?) -> Void) {
        guard let data = try? Data(contentsOf: url) else {
            completion(nil)
            return
        }
       parseXML(data: data, elementName: elementName, completion: completion)
    }
    
    func parseXML(data:Data,
                  completion:@escaping (XMLDictionary?) -> Void) {
        let parser = XMLParser(data: data)
        self.completion = completion
        let helperParser = ParserAllTags(completion: completion)
        parser.delegate = helperParser
        parser.parse()
    }
    
    func parseXML(data:Data,
                  elementName:String,
                  completion:@escaping(Array<XMLDictionary>?) -> Void) {
        let parser = XMLParser(data: data)
        self.completionArray = completion
        let helperParser = ParserSpecificElement(elementName: elementName, completion:completion)
        parser.delegate = helperParser
        parser.parse()
    }
    
    @available(iOS 13.0, *)
    func parseXML(atURL url:URL) -> AnyPublisher<XMLDictionary?, Never> {
        let subject = CurrentValueSubject<XMLDictionary?, Never>(nil)
        parseXML(atURL: url) { dictionary in
            subject.send(dictionary)
        }
        return subject.eraseToAnyPublisher()
    }
    
    @available(iOS 13.0, *)
    func parseXML(data: Data) -> AnyPublisher<XMLDictionary?, Never> {
        let subject = CurrentValueSubject<XMLDictionary?, Never>(nil)
        parseXML(data:data) { dictionary in
            subject.send(dictionary)
        }
        return subject.eraseToAnyPublisher()
    }
    
    @available(iOS 13.0, *)
    func parseXML(atURL url:URL, elementName:String) -> AnyPublisher<Array<XMLDictionary>?, Never> {
        let subject = CurrentValueSubject<Array<XMLDictionary>?, Never>(nil)
        parseXML(atURL: url, elementName: elementName) { arrayDictionary in
            subject.send(arrayDictionary)
        }
        return subject.eraseToAnyPublisher()
    }
    
    @available(iOS 13.0, *)
    func parseXML(data:Data, elementName:String) -> AnyPublisher<Array<XMLDictionary>?, Never> {
        let subject = CurrentValueSubject<Array<XMLDictionary>?, Never>(nil)
        parseXML(data:data, elementName: elementName) { arrayDictionary in
            subject.send(arrayDictionary)
        }
        return subject.eraseToAnyPublisher()
    }
    
    // MARK: - Private
    
    private var completionArray:((Array<XMLDictionary>?) -> Void)?
    private var completion:((XMLDictionary?) -> Void)?
}

// MARK: - ParserSpecificElement

fileprivate class ParserSpecificElement:NSObject, XMLParserDelegate {
    init(elementName:String, completion:@escaping (Array<XMLDictionary>?) -> Void) {
        self.elementNameToGet = elementName
        self.completion = completion
    }
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        currentElementName = nil
        if elementName == elementNameToGet {
            newDictionary()
        }
        else if currentDictionary != nil {
            currentElementName = elementName
        }
        if let currentElementName = currentElementName {
            addAttributes(attributeDict, forKey:currentElementName)
        }
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        if elementName == elementNameToGet {
            addCurrentDictionaryToResults()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let key = currentElementName {
            addString(string, forKey: key)
        }
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if let _ = elementNameToGet {
            completion(results)
        }
    }

    // MARK: - Private
    
    private var completion:(Array<XMLDictionary>?) -> Void
    private var currentDictionary:XMLDictionary?
    private var currentElementName:String?
    private var elementNameToGet:String?
    private var results:[XMLDictionary] = []
    
    private func addAttributes(_ attributes:[String:String], forKey key:String) {
        currentDictionary?[key] = XMLElement(value: "", attributes: attributes)
    }
    
    private func addCurrentDictionaryToResults() {
        if let currentDictionary = currentDictionary {
            results.append(currentDictionary)
        }
        currentDictionary = nil
    }
    
    private func addString(_ string:String, forKey key:String) {
        if let currentValue = currentDictionary?[key] as? XMLElement {
            let valueString = currentValue.value + string
            currentDictionary?[key] = XMLElement(value: valueString, attributes: currentValue.attributes)
        }
        else {
            currentDictionary?[key] = XMLElement(value: string, attributes: [:])
        }
    }
    
    private func newDictionary() {
        currentDictionary = [:]
    }
}




// MARK: - ParserAllTags

fileprivate class ParserAllTags:NSObject, XMLParserDelegate {
    
    init(completion:@escaping (XMLDictionary?) -> Void) {
        self.completion = completion
    }
    
    private var completion:(XMLDictionary?) -> Void
    private var currentDictionary:XMLDictionary = [:]
    private var currentElementName:String = ""
    private var rootDictionary:XMLDictionary = [:]
    private var stack:[XMLDictionary] = []
    
    /// Add a dictionary to an existing one
    /// If the key is already in the dictionary we need to create an array
    /// - Parameters:
    ///   - dictionary: the dictionary to add
    ///   - toDictionary: the dictionary where the given dictionary will be added
    ///   - key: the key
    /// - Returns: the dictionary passed as toDictionary with the new value added
    private func addDictionary(_ dictionary:XMLDictionary, toDictionary:XMLDictionary,
                                      key:String) -> XMLDictionary {
        var returnDictionary = toDictionary
        if let array = returnDictionary[key] as? Array<XMLDictionary> {
            var newArray = array
            newArray.append(dictionary)
            returnDictionary[key] = newArray
        }
        else if let dictionary = returnDictionary[key] as? XMLDictionary {
            var array:[XMLDictionary] = [dictionary]
            array.append(dictionary)
            returnDictionary[key] = array
        }
        else {
            returnDictionary[key] = dictionary
        }
        return returnDictionary
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        stack.append(currentDictionary)
        currentDictionary = [:]
        currentElementName = elementName
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        var parentDictionary = stack.removeLast()
        parentDictionary = addDictionary(currentDictionary, toDictionary: parentDictionary, key: elementName)
        currentDictionary = parentDictionary
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if string == "\n" {
            return
        }
        if let currentValue = currentDictionary[currentElementName] as? XMLElement {
            let valueString = currentValue.value + string
            currentDictionary[currentElementName] = XMLElement(value: valueString, attributes: currentValue.attributes)
        }
        else {
            currentDictionary[currentElementName] = XMLElement(value: string, attributes: [:])
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        completion(currentDictionary)
    }
}

