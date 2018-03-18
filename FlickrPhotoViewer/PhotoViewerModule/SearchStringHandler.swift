//
//  SearchStringHandler.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 18/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation

protocol SearchStringHandlerDelegate: class {
    func canSearchString(_ string: String)
}

protocol SearchStringHandler {
    var delegate: SearchStringHandlerDelegate? {set get}
    var searchString: String? {get}
    func stringChanged(to string: String)
}

class SearchStringDelayedHandler: SearchStringHandler {
    
    weak var delegate: SearchStringHandlerDelegate?
    private let delayInFractionOfSeconds: Double
    var searchString: String? = nil
    private var timer = Timer()
    
    init(delayInMs: Int) {
        self.delayInFractionOfSeconds = Double(delayInMs) / 1000.0
    }
    
    func stringChanged(to string: String) {
        searchString = string
        if timer.isValid {
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: delayInFractionOfSeconds,
                      repeats: false,
                      block: { _ in
                 self.delegate?.canSearchString(self.searchString!)
        })
            
        
    }
}
