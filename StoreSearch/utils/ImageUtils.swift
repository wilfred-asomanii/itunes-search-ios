//
//  ImageUtils.swift
//  StoreSearch
//
//  Created by Wilfred Asomani on 16/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {

    func setImage(fromURL url: String?) {
        image = UIImage(named: "Placeholder")
        guard let url = url else { return }
        let task = URLSession.shared.dataTask(with: URL(string: url)!) {
            [weak self] data, response, error in
            guard error == nil else { return }
            guard validateStatus(of: response) else { return }
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.layer.cornerRadius = self.bounds.width / 2
                self.clipsToBounds = true
                self.image = image
            }
        }
        task.resume()
    }
    
}
