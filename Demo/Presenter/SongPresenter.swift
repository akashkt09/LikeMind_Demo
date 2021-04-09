//
//  SongPresenter.swift
//  Demo
//
//  Created by Akash on 09/04/21.
//

import Foundation


protocol getSongsProtocol: NSObjectProtocol {
  
   func getSongs(response: SongModel)
   func songsFailure(errorMessage: String)
   
}

class SongsPresenter {
    
    weak var songsProtocol: getSongsProtocol?
    
    func attachView(view: getSongsProtocol){
        songsProtocol = view
    }
    
    func detachView() {
        songsProtocol = nil
    }
    
    //Get Data
    func fetchResponse(parameters: [String: Any]?, showLoader: Bool){
        if showLoader {
            Loader.showLoader(title: "Loading")
        }
        NetworkManager.GetSongList(parameters: parameters) { [weak self] result in
            Loader.hideLoader()
            
            guard self != nil else{return}//-------
            
            switch result {
            case let .success(response):
                if response.statusCode == 200
                {
                    if let responseData = response.data  {
                        self?.songsProtocol?.getSongs(response: responseData)
                    }
                }
               
            case .failure(let error):
                self?.songsProtocol?.songsFailure(errorMessage: "\(error.localizedDescription())")
                break
            }
        }
    }
}
