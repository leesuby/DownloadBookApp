//
//  Book.swift
//  BookDownload
//
//  Created by LAP15335 on 08/09/2022.
//

import Foundation


class Book{
    var url : String
    var name : String
    var index : Int
    
    init(url : String, name : String, index : Int){
        self.url = url
        self.name = name
        self.index = index
    }
}
