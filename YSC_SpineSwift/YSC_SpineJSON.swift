//
//  YSC_SpineJSON.swift
//  YSC_SKSpine_New
//
//  Created by 최윤석 on 2015. 11. 5..
//  Copyright © 2015년 Yoonsuk Choi. All rights reserved.
//

import Foundation

class YSC_SpineJSONTools {
    func readJSONFile(_ name:String) -> JSON {
        
        let path = Bundle.main.path(forResource: name, ofType: "json")
        var jsonData = Data()
        var jsonResult:JSON!
        do {
            jsonData = try Data(contentsOf: URL(fileURLWithPath: path!), options: .uncached)
            jsonResult = try JSON(data: jsonData)
            
        } catch let error as NSError {
            print(error.domain)
            jsonResult = JSON(arrayLiteral: [])
        }
        
        
        
        return jsonResult
    }
}
