//
//  DetailViewController.swift
//  AwesomeNotes
//
//  Created by Saikumar Kankipati on 2/22/20.
//  Copyright © 2020 Saikumar Kankipati. All rights reserved.
//

import UIKit

class AwesomeNotesDetailViewController: UIViewController {

	@IBOutlet var noteTitleLabel: UILabel!
    @IBOutlet var noteTextTextView: UITextView!
    @IBOutlet var noteDate: UILabel!
	
	var noteTimeStamp = Date().toSeconds()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		setupView()
	}
	
	func setupView() {
		if let detail = detailItem {
			if let noteTitleLabel = noteTitleLabel,
				let noteDate = noteDate,
				let noteTextTextView = noteTextTextView {
				noteTitleLabel.text = detail.noteTitle
				noteDate.text = AwesomeNotesCreateEditViewController.convertDate(date: Date.init(seconds: detail.noteTimeStamp))
				noteTextTextView.text = detail.noteText
			}
		}
	}
	
	var detailItem: AwesomeNote? {
		didSet {
		setupView()
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		   if segue.identifier == "showEditNoteSegue" {
			   let editNoteVC = segue.destination as! AwesomeNotesCreateEditViewController
			   if let detail = detailItem {
				editNoteVC.existingNote = detail
			   }
		   }
	   }
}

