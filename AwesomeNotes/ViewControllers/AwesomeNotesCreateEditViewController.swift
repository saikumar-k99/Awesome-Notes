//
//  AwesomeNotesCreateEditViewController.swift
//  AwesomeNotes
//
//  Created by Saikumar Kankipati on 2/23/20.
//  Copyright © 2020 Saikumar Kankipati. All rights reserved.
//

import UIKit
import CoreData

class AwesomeNotesCreateEditViewController: UIViewController {
	
	@IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteSaveButton: UIButton!
    @IBOutlet weak var noteDateLabel: UILabel!
	
	let entityName = "AwesomeNote"
	
	var managedObjectContext: NSManagedObjectContext? = AppDelegate.viewContext
	
	private let noteCreationTimeStamp : Int64 = Date().toSeconds()
	var existingNote : AwesomeNote?

	@IBAction func noteTitleChanged(_ sender: UITextField, forEvent event: UIEvent) {
		if self.existingNote != nil {
				// is in edit mode
				noteSaveButton.isEnabled = true
			} else {
				// create mode
				if ( sender.text?.isEmpty ?? true ) {
					noteSaveButton.isEnabled = false
				} else {
					noteSaveButton.isEnabled = true
				}
			}
    }
    
    @IBAction func saveTapped(_ sender: UIButton, forEvent event: UIEvent) {
			   if self.existingNote != nil {
				   editItem()
			   } else {
				   createNote()
			   }
    }
	
	private func createNote() -> Void {
		guard let managedObjectContext = managedObjectContext else { return }
		guard let title = noteTitleTextField.text, !title.isEmpty else {
			showAlert(with: "Title is Missing", and: "Your note doesn't have a title.")
			return
		}
		
		let note = AwesomeNote(context: managedObjectContext)
		note.noteId = UUID()
		note.noteText = noteTextTextView.text
		note.noteTimeStamp = noteCreationTimeStamp
		note.noteTitle = noteTitleTextField.text
		
		do {
			try managedObjectContext.save() }
		catch {
			print("save failed")
		}
		
		performSegue(
			withIdentifier: "backToMasterView",
			sender: self)
	}
	
	private func editItem() -> Void {
		// use existing note
		if let existNote = self.existingNote {
			let fetchRequest = NSFetchRequest<AwesomeNote>(entityName: entityName)
			let predicate = NSPredicate(format: "noteId = %@", existNote.noteId! as CVarArg)
			fetchRequest.predicate = predicate
			do {
				let currentNote = try self.managedObjectContext?.fetch(fetchRequest)
				
				if currentNote?.count == 1 {
					if let noteToUpdate = currentNote?.first {
						noteToUpdate.noteText = self.noteTextTextView.text
						noteToUpdate.noteTimeStamp = self.noteCreationTimeStamp
						noteToUpdate.noteTitle = self.noteTitleTextField.text
					}
				}
				
				try managedObjectContext?.save()
				
			} catch {
				print("error")
			}
		  
			self.performSegue(
			withIdentifier: "backToMasterView",
			sender: self)
			
		} else {
			showAlertAndGoBack()
		}
	}
	
	func showAlertAndGoBack() {
		let alert = UIAlertController(
					   title: "Unexpected error",
					   message: "Cannot edit the note, unexpected error occurred. Try again later.",
					   preferredStyle: .alert)

				   alert.addAction(UIAlertAction(title: "OK",
												 style: .default ) { (_) in self.performSegue(
													 withIdentifier: "backToMasterView",
													 sender: self)})
				   self.present(alert, animated: true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		if let existingNote = self.existingNote {
			noteTitleTextField.text = existingNote.noteTitle
			noteTextTextView.text = existingNote.noteText
			noteDateLabel.text = AwesomeNotesCreateEditViewController.convertDate(date: Date.init(seconds: noteCreationTimeStamp))
			// enable done button by default
			noteSaveButton.isEnabled = true
		} else {
			noteDateLabel.text = AwesomeNotesCreateEditViewController.convertDate(date: Date.init(seconds: noteCreationTimeStamp))
		}
		
		noteTextTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
		noteTextTextView.layer.borderWidth = 1.0
		noteTextTextView.layer.cornerRadius = 5
		
		// Back button
		let backButton = UIBarButtonItem()
		backButton.title = "Back"
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		noteTitleTextField.becomeFirstResponder()
	}
	
	static func convertDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        let yourDate = formatter.date(from: dateString)
        formatter.dateFormat = "EEEE, MMM d, yyyy, hh:mm:ss"
        let convertedString = formatter.string(from: yourDate!)
        return convertedString
    }
}
