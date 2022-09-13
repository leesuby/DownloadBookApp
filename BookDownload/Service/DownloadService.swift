//
//  DownloadService.swift
//  BookDownload
//
//  Created by LAP15335 on 13/09/2022.
//

import Foundation

class DownloadService{
    
    
    //Map URL -> DownloadTask
    var activeDownloads: [URL: DownloadBook] = [ : ]
    
    var downloadsSession: URLSession!
    
    func startDownload(_ book: Book) {
        
        //Already download this book file before
        if (activeDownloads[URL(string: book.url)!] != nil){
        
            let download = activeDownloads[URL(string: book.url)!]!
            
            download.task.append(downloadsSession.downloadTask(with: URL(string: book.url)!))
            
            download.task[download.task.endIndex - 1]?.resume()
        }
        
        // Download for first time
        else{
  
            let download = DownloadBook(book: book)
            
            download.task.append(downloadsSession.downloadTask(with: URL(string: book.url)!))

            download.task[download.task.endIndex - 1]?.resume()
         
            activeDownloads[URL(string: book.url)!] = download
           
        }
    }
    
    func cancelDownload(_ book : Book){
        
        if (activeDownloads[URL(string: book.url)!] != nil && activeDownloads[URL(string: book.url)!]?.task != [] ){
        
            let download = activeDownloads[URL(string: book.url)!]!
        
            download.task[download.task.endIndex - 1]?.cancel()
        }
        
        // Nothing to cancel
        else{
  
        }
    }
}
