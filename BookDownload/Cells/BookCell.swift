//
//  BookCell.swift
//  BookDownload
//
//  Created by LAP15335 on 08/09/2022.
//

import UIKit

protocol BookCellDelegate {
    func downloadBook(book: Book)
    func cancelBook(book: Book)
    func deleteBook(book: Book)
    func printBook(book: Book)
}

class BookCell: UICollectionViewCell {
    
    
    var url : String!
    var bookFileName : URL!
    var book : Book!
    var delegate : BookCellDelegate?
    
    
    let name = UILabel()
    
    let downloadedText = UILabel()
    let downloadedCount = UILabel()
    var countDownloaded: Int = 0
    
    let downloadingText = UILabel()
    let downloadingCount = UILabel()
    var countDownloading: Int = 0
    
    let result = UITextView()
    
    let buttonDelete = UIButton()
    let buttonDownload = UIButton()
    let buttonCancel = UIButton()
    let buttonPrint = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let separator = UIView(frame: .zero)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .quaternaryLabel
        
        name.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 30, weight: .bold))
        name.textColor = .label
        
        downloadedText.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .bold))
        downloadedText.textColor = .systemBlue
        downloadedText.text = "Downloaded: "
        
        downloadedCount.font = .preferredFont(forTextStyle: .body)
        downloadedCount.textColor = .darkGray
        
        downloadingText.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .bold))
        downloadingText.textColor = .systemBlue
        downloadingText.text = "Downloading: "
        
        downloadingCount.font = .preferredFont(forTextStyle: .body)
        downloadingCount.textColor = .darkGray
        

        result.font = .preferredFont(forTextStyle: .body)
        result.isEditable = false
        
        buttonDelete.setTitle("Delete", for: .normal)
        buttonDelete.backgroundColor = .systemBlue
        buttonDelete.addTarget(self, action: #selector(BtnDeleteBook), for: .touchUpInside)
        buttonDelete.configuration = .filled()
        buttonDelete.layer.cornerRadius = 5
        buttonDelete.layer.borderWidth = 0.5
        buttonDelete.layer.borderColor = UIColor.white.cgColor
        
        buttonDownload.setTitle("Download", for: .normal)
        
        buttonDownload.backgroundColor = .systemBlue
        buttonDownload.addTarget(self, action: #selector(BtnDownloadBook), for: .touchUpInside)
        buttonDownload.configuration = .filled()
        buttonDownload.layer.cornerRadius = 5
        buttonDownload.layer.borderWidth = 0.5
        buttonDownload.layer.borderColor = UIColor.white.cgColor
        
        buttonCancel.setTitle("Cancel", for: .normal)
        buttonCancel.backgroundColor = .systemBlue
        buttonCancel.addTarget(self, action: #selector(BtnCancelBook), for: .touchUpInside)
        buttonCancel.configuration = .filled()
        buttonCancel.layer.cornerRadius = 5
        buttonCancel.layer.borderWidth = 0.5
        buttonCancel.layer.borderColor = UIColor.white.cgColor
        
        buttonPrint.setTitle("Print", for: .normal)
        buttonPrint.backgroundColor = .systemBlue
        buttonPrint.addTarget(self, action: #selector(BtnPrintBook), for: .touchUpInside)
        buttonPrint.configuration = .filled()
        buttonPrint.layer.cornerRadius = 5
        buttonPrint.layer.borderWidth = 0.5
        buttonPrint.layer.borderColor = UIColor.white.cgColor
        
        
        let downloadStackView = UIStackView(arrangedSubviews: [downloadedText,downloadedCount,downloadingText,downloadingCount])
        
        downloadStackView.axis = .horizontal
        downloadStackView.alignment = .leading
        downloadStackView.spacing = 0
        downloadStackView.distribution = .equalSpacing
        
        let buttonStackView = UIStackView(arrangedSubviews: [buttonDownload,buttonCancel,buttonDelete,buttonPrint])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .leading
        buttonStackView.spacing = 0
        buttonStackView.distribution = .equalSpacing
        
        let finalStackView = UIStackView(arrangedSubviews: [separator,name,downloadStackView,buttonStackView,result])
        finalStackView.axis = .vertical
        finalStackView.translatesAutoresizingMaskIntoConstraints = false
        finalStackView.spacing = 10
        
        contentView.addSubview(finalStackView)
        
        NSLayoutConstraint.activate([
            finalStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            finalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            finalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            finalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)])
    }
    
    //Config 
    func config(book: Book, fileExist : Int){
        url = book.url
        name.text = book.name
        
        countDownloaded = fileExist
        downloadedCount.text = String(countDownloaded)
        downloadingCount.text = "0"
        
        self.book = book
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error")
    }
    
    
    //Action
    @objc private func BtnDeleteBook(sender :UIButton){
        
        if let del = delegate{
            del.deleteBook(book: self.book)
        }
    }
    
    @objc private func BtnDownloadBook(sender: UIButton){
        if let del = delegate{
            del.downloadBook(book: self.book)
            
            countDownloading += 1
            downloadingCount.text = String(countDownloading)
        }
        
    }
    
    @objc private func BtnCancelBook(sender: UIButton){
        if let del = delegate{
            
            del.cancelBook(book: self.book)
            
            if(countDownloading > 0)
            {countDownloading -= 1}
            downloadingCount.text = String(countDownloading)
        }
    }
    
    @objc private func BtnPrintBook(sender: UIButton){
        if let del = delegate{
            
            del.printBook(book: self.book)
        
        }
    }
    
    func downloadDone(){
        countDownloading -= 1
        downloadingCount.text = String(countDownloading)
        
        countDownloaded += 1
        downloadedCount.text = String(countDownloaded)
    }
    
    func deleteDone(){
        if(countDownloaded > 0){
            countDownloaded -= 1
            downloadedCount.text = String(countDownloaded)}
    }
    
    
    
    
    
}
