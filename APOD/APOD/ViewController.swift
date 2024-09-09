//
//  ViewController.swift
//  APOD
//
//  Created by 홍진표 on 9/8/24.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    /// Behavioral Pattern: `Observer`
    private var apod: Apod? {
        willSet {
            print("willSet: \(String(describing: newValue)) \n")
        }
        
        didSet {
            print("DidSet: \(String(describing: oldValue)) \n")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .systemBackground
    }
    
    /// View가 등장할 때, Model의 상태가 변경되었는지 확인하기 위해 `viewWillAppear()` 호출
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .background).async {
            APICaller.shared.fetchApod { [weak self] result in
                guard let self: ViewController = self else { return }
                
                switch result {
                case .success(let apod):
                    self.apod = apod
                    break;
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    break;
                }
            }
        }
    }


}

#Preview(body: {
    ViewController()
})

