//
//  ViewController.swift
//  BookDownload
//
//  Created by LAP15335 on 08/09/2022.
//

import UIKit

class ViewController: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    //Session for download
    private lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    let downloadService = DownloadService()
    
    //Data source
    var dataSource : [Book] = [
        Book(url: "https://www.tutorialspoint.com/swift/swift_tutorial.pdf", name: "swift_tutorial", index: 0),
        Book(url: "http://www.cs.nthu.edu.tw/~ychung/slides/CSC3150/Abraham-Silberschatz-Operating-System-Concepts---9th2012.12.pdf" ,name: "Abraham-Silberschatz-Operating-System-Concepts---9th2012.12",index:  1),
        Book(url: "http://www.cs.unibo.it/~babaoglu/courses/security/resources/documents/Computer_Security_Principles_and_Practice_(3rd_Edition).pdf" ,name: "Computer_Security_Principles_and_Practice_(3rd_Edition)", index:  2)]
    
    var numberOfFileExist: [Int] = [0,0,0]
    
    //View
    var collectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Service
        downloadService.downloadsSession = downloadsSession
        
        setView()
        
    }
    
    func setView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "bookCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive=true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive=true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive=true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive=true
        
        // Do any additional setup after loading the view.
    }
    
    //Count how many file which had already download
    func countFile(book : Book) -> Int{
        var count : Int = 0
        do{
            
            let fileMngr = FileManager.default;
            
            let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: false)
            
            let allFile = try? fileMngr.contentsOfDirectory(atPath: documentsURL.path)
            for item in allFile!{
                if(item.contains("\(book.name)")){
                    count += 1
                }
            }
        }
        catch{
        }
        return count
    }
    
}

// DataSource & Delegate CollectionView
extension ViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if let bookCell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as? BookCell{
            
            let book = dataSource[indexPath.row]
            
            bookCell.config(book: book ,fileExist: countFile(book: book))
            bookCell.delegate = self
            bookCell.backgroundColor = .white
            cell = bookCell
        }
        
        return cell
    }
    
    
}

//FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 20, height: 200)
    }
}



//Delegate for BookCell
extension ViewController: BookCellDelegate{
    
    func downloadBook(book: Book) {
        downloadService.startDownload(book)
    }
    
    
    func cancelBook(book: Book) {
        downloadService.cancelDownload(book)
    }
    
    func deleteBook(book: Book) {
        do {
            var numberOfFile : Int = 0
            
            let cell : BookCell = self.collectionView.cellForItem(at: IndexPath(row: (book.index), section: 0)) as! BookCell
            
            cell.deleteDone()
            
            numberOfFile = cell.countDownloaded
            
            let fileName = book.name + "(\(String(numberOfFile + 1))).pdf"
            let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: false)
            let deleteatURL = documentsURL.appendingPathComponent(fileName)
            try FileManager.default.removeItem(at: deleteatURL)
            print("\(fileName) has been deleted")
        } catch {
            print(error)
        }
    }
    
    func printBook(book: Book) {
        
        let cell : BookCell = self.collectionView.cellForItem(at: IndexPath(row: (book.index), section: 0)) as! BookCell
        
        cell.result.text="Result:\n"
        
        do{
            let fileMngr = FileManager.default;
            
            let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: false)
            
            let allFile = try? fileMngr.contentsOfDirectory(atPath: documentsURL.path)
            for item in allFile!{
                if(item.contains("\(book.name)")){
                    cell.result.text += item + "\t"
                }
            }
        }
        catch{
            
        }
        
        
    }
    
    //Callback when file is finishing download
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        // check for and handle errors:
        // * downloadTask.response should be an HTTPURLResponse with statusCode in 200..<299
        do {
            guard let sourceURL = downloadTask.originalRequest?.url else {
                return
            }
            
            //check which task is finished
            let download = downloadService.activeDownloads[sourceURL]
            downloadService.activeDownloads[sourceURL]?.task.removeFirst()
            
            var numberOfFile : Int = 0
            
            //Update UI
            DispatchQueue.main.sync {
                
                let cell : BookCell = self.collectionView.cellForItem(at: IndexPath(row: (download?.book.index)!, section: 0)) as! BookCell
                
                cell.downloadDone()
                
                numberOfFile = cell.countDownloaded
            }
            
            //Save File
            let fileNameOriginal = downloadTask.originalRequest!.url!.lastPathComponent
            
            let fileName = fileNameOriginal.prefix(fileNameOriginal.count - 4) + "(\(String(numberOfFile))).pdf"
            
            let documentsURL = try
            FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
            
            let savedURL = documentsURL.appendingPathComponent(
                String(fileName) )
            try FileManager.default.moveItem(at: location, to: savedURL)
        } catch {
            // handle filesystem error
        }
    }
    
}
