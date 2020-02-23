//
//  Date+Extension.swift
//  AwesomeNotes
//
//  Created by Saikumar Kankipati on 2/23/20.
//  Copyright © 2020 Saikumar Kankipati. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func toSeconds() -> Int64! {
        return Int64((self.timeIntervalSince1970).rounded())
    }
    
    init(seconds:Int64!) {
        self = Date(timeIntervalSince1970: TimeInterval(Double.init(seconds)))
    }
}

extension UIViewController {

    func showAlert(with title: String, and message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

}
