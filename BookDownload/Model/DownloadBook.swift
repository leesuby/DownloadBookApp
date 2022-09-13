//
//  DownloadBook.swift
//  BookDownload
//
//  Created by LAP15335 on 13/09/2022.
//

import Foundation


class DownloadBook{
    //for download multiple file on 1 book
    var task : [URLSessionDownloadTask?] = []
    var book : Book
    
    init(book: Book){
        self.book = book
    }
}
