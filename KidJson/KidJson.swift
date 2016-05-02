//
//  KidJson.swift
//  kotowaza
//
//  Created by NguyenTheQuan on 2016/04/22.
//  Copyright © 2016年 Kid. All rights reserved.
//

import Foundation

let ERROR_DOMAIN:String = "kid.json"
let EROOR_CODE:Int = 1412

class KidJson: NSObject
{
    func setUpWithDictionary(dataDic: NSDictionary?, error: NSErrorPointer)
    {
        if dataDic == nil {
            let info = [NSLocalizedDescriptionKey: "Json data is nil"]
            if error != nil
            {
                error.memory = NSError(domain: ERROR_DOMAIN, code: EROOR_CODE, userInfo: info)
            }
            return
        }
        
        matchWithPropertiesDictionary(dataDic!, error: error)
    }
    
    private func getClassPropertes() -> Dictionary<String, String>
    {
        var results: Dictionary<String, String> = [String: String]()
        
        // Get SubClass
        var clsName = String(self).componentsSeparatedByString(":").first!
        clsName = clsName.componentsSeparatedByString("<").last!
        let myClass: AnyClass = NSClassFromString(clsName)!
        
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0
        let properties = class_copyPropertyList(myClass, &count)
        
        // iterate each objc_property_t struct
        for i: UInt32 in 0 ..< count
        {
            let property = properties[Int(i)]
            
            // Get the property type
            let cpropType = property_getAttributes(property)
            let propType = getPropertyType(cpropType)
            
            // retrieve the property name by calling property_getName function
            let cname = property_getName(property)
            
            // convert the c string into a swift string
            let name = String.fromCString(cname)
            
            results[name!] = propType
        }
        
        // release objc_property_t structs
        free(properties)
        
        return results;
    }
    
    private func getPropertyType(attributes: UnsafePointer<Int8>) -> String {
        
        var str = String.fromCString(attributes)
        if str == nil || str!.isEmpty {
            return ""
        }
        
        str = str?.componentsSeparatedByString(",").first!
        
        return (str?.componentsSeparatedByString("\"")[1])!
    }
    
    private func camelCaseToUnderscores(input: String) -> String {
        let output: NSMutableString = NSMutableString()
        let uppercase = NSCharacterSet.uppercaseLetterCharacterSet()
        for idx: Int in 0 ..< input.characters.count {
            let c: unichar = (input as NSString).characterAtIndex(idx)
            let addString = String(Character(UnicodeScalar(c))).lowercaseString;
            if uppercase.characterIsMember(c) {
                output.appendFormat("_%@", addString)
            }
            else
            {
                output.appendFormat("%@", addString)
            }
        }
        
        return output as String
    }
    
    private func matchWithPropertiesDictionary(jsonData: NSDictionary, error: NSErrorPointer)
    {
        let propertiesDic = getClassPropertes()
        for kp in propertiesDic.keys {
            let jsonKey = camelCaseToUnderscores(kp)
            let data = jsonData[jsonKey]
            if data != nil
            {
                let proType = propertiesDic[kp]
                if data!.isKindOfClass(NSClassFromString(proType!)!) {
                    self.setValue(data, forKey: kp)                    
                }
                else
                {
                    if error != nil {
                        let erString = String.init(format: "Not match type: %@ Key %@", proType!, jsonKey)
                        let info = [NSLocalizedDescriptionKey: erString]
                        error.memory = NSError(domain: ERROR_DOMAIN, code: EROOR_CODE, userInfo: info)
                    }
                    
                    break;
                }
            }
            else
            {
                if error != nil {
                    let erString = String.init(format: "Not have data for this property: %@", kp)
                    let info = [NSLocalizedDescriptionKey: erString]
                    error.memory = NSError(domain: ERROR_DOMAIN, code: EROOR_CODE, userInfo: info)
                }
                
                break;
            }
        }
    }
}
