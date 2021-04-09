//
//  ViewController.swift
//  Demo
//
//  Created by Akash on 09/04/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchContainerView: UIView!{
        didSet{
            searchContainerView.layer.cornerRadius = searchContainerView.frame.size.height/2
            searchContainerView.clipsToBounds = true
        }
    }
    @IBOutlet weak var viewCollection: UICollectionView!
    @IBOutlet weak var searchTxtFld: UITextField!
    var refreshControl: UIRefreshControl?
    
    private let spacing:CGFloat = 8.0
    var apiResponse: [SongList]?
    
    fileprivate let songsPresenter = SongsPresenter()
    var pageNumber = 1
    var searchKeyword = "add"

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewCollection.keyboardDismissMode = .onDrag
        viewCollection.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
    
        viewCollection.reloadData()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.viewCollection?.collectionViewLayout = layout
        
        searchTxtFld.delegate = self
        
        songsPresenter.attachView(view: self)
        
        getDataList(showLoader: true)
        
        refreshControl = UIRefreshControl()
            self.viewCollection!.alwaysBounceVertical = true
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        if let refresh = refreshControl
        {
            self.viewCollection.addSubview(refresh)
        }
    }

    
    //Start Refresh Control
    @objc func loadData() {
        self.view.endEditing(true)
        self.viewCollection.refreshControl?.beginRefreshing()
        pageNumber = 1
        searchKeyword = "add"
        getDataList(showLoader: false)
    }
    
    //Stop Refresh Control
    func stopRefresher() {
        self.refreshControl?.endRefreshing()
    }
    
    //API call function
    private func getDataList(showLoader: Bool) {
        
        var dict = [String: AnyObject]()
        dict["apikey"] = "7d58cc52" as AnyObject
        dict["s"] = (searchKeyword != "" ? searchKeyword : "add") as AnyObject
        dict["page"] = (searchKeyword != "" ? pageNumber : 1) as AnyObject
        
        songsPresenter.fetchResponse(parameters: dict, showLoader: showLoader)
    }

}

// Collection View Datasource and Delegates
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return apiResponse?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.songModel = apiResponse?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let numberOfItemsPerRow:CGFloat = 2
        let spacingBetweenCells:CGFloat = 8

        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row

        if let collection = self.viewCollection{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: ((collectionView.frame.size.width / 2)+50))
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
}


//Get Data from API
extension ViewController: getSongsProtocol {
    func getSongs(response: SongModel) {
        
        if let resp = response.response,
           resp.caseInsensitiveCompare("True") == .orderedSame{
            if self.pageNumber == 1 {
                apiResponse = response.search
            }else{
                apiResponse = (apiResponse ?? []) + response.search
            }
        }else{
            print("error")
        }
        viewCollection.reloadData()
        
        self.stopRefresher()
    }
    
    func songsFailure(errorMessage: String) {
        
    }
    
}


//Scroll View Delegate
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if maximumOffset - currentOffset <= -40 && ((self.apiResponse?.count ?? 0) % 10 == 0) && (self.apiResponse?.count ?? 0) > 0 {
            pageNumber += 1
            self.getDataList(showLoader: true)
        }
    }
}


//TextField Delegate
extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty {
            searchKeyword = String(searchKeyword.dropLast())
        } else {
            searchKeyword = textField.text! + string
        }
        
        if searchKeyword.count >= 3 || searchKeyword.count == 0
        {
            self.showSearchText(str: searchKeyword)
        }
        
        return true
    }
    
    func showSearchText(str:String)
    {
        getDataList(showLoader: false)
    }
}
