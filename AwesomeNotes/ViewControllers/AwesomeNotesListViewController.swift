//
//  MasterViewController.swift
//  AwesomeNotes
//
//  Created by Saikumar Kankipati on 2/22/20.
//  Copyright © 2020 Saikumar Kankipati. All rights reserved.
//

import UIKit
import CoreData

class AwesomeNotesListViewController: UITableViewController {
	
	let entityName = "AwesomeNote"
	var detailViewController: AwesomeNotesDetailViewController? = nil
	var managedObjectContext: NSManagedObjectContext? = AppDelegate.viewContext

	var fetchedResultsController: NSFetchedResultsController<AwesomeNote> {
		
		let fetchRequest: NSFetchRequest<AwesomeNote> = NSFetchRequest<AwesomeNote>(entityName: entityName)
		
		// Set the batch size to a suitable number.
		fetchRequest.fetchBatchSize = 20
		
		// Edit the sort key as appropriate.
		let sortDescriptor = NSSortDescriptor(key: "noteTimeStamp", ascending: false)
		
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		let resultsControler = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
		resultsControler.delegate = self
	  
		
		do {
			try resultsControler.performFetch()
		} catch {
			 let nserror = error as NSError
			 showAlert(with: "Unable to load notes", and: "Please try again later!!")
		}
		
		return resultsControler
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		navigationItem.leftBarButtonItem = editButtonItem

		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewNote(_:)))
		navigationItem.rightBarButtonItem = addButton
		
		if let split = splitViewController {
		    let controllers = split.viewControllers
		    detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? AwesomeNotesDetailViewController
		}

	}

	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}

	@objc
	func insertNewNote(_ sender: Any) {
		performSegue(withIdentifier: "showCreateNoteSegue", sender: self)
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = tableView.indexPathForSelectedRow {
				let selectedNote = fetchedResultsController.object(at: indexPath)
		        let controller = (segue.destination as! UINavigationController).topViewController as! AwesomeNotesDetailViewController
		        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		        controller.navigationItem.leftItemsSupplementBackButton = true
		        detailViewController = controller
				detailViewController?.detailItem = selectedNote
		    }
		} else if segue.identifier == "showCreateNoteSegue" {
			guard let vc = segue.destination as? AwesomeNotesCreateEditViewController else {
				return
			}
			
			vc.managedObjectContext = AppDelegate.viewContext
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath) as? NotesCell else {
			return UITableViewCell()
		}
		
		setupNotesCell(cell: cell, indexPath: indexPath)
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let context = fetchedResultsController.managedObjectContext
			let note = self.fetchedResultsController.object(at: indexPath)
			context.delete(note)
			do {
				try context.save()
				
				UIView.animate(withDuration: 1.0, delay: 2.0, options: .curveEaseIn, animations: {
					tableView.reloadData()
				}, completion: nil)
				
			} catch {
				let nserror = error as NSError
				showAlert(with: "Error while saving files", and: "Try again!!")
			}
		}
	}
	
	func setupNotesCell(cell: NotesCell, indexPath: IndexPath) {
		let note = fetchedResultsController.object(at: indexPath)
		cell.noteTitleLabel.text = note.noteTitle
		cell.noteTextLabel?.text = note.noteText
		cell.noteDateLabel.text = AwesomeNotesCreateEditViewController.convertDate(date: Date.init(seconds: note.noteTimeStamp))
		
	}
}

extension AwesomeNotesListViewController: NSFetchedResultsControllerDelegate {
		func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
			tableView.beginUpdates()
		}

		func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
			switch type {
			case .insert:
				tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
			case .delete:
				tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
			default:
				return
			}
		}

		func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
			switch (type) {
				   case .insert:
					   if let indexPath = newIndexPath {
						   tableView.insertRows(at: [indexPath], with: .fade)
					   }
				   case .delete:
					   if let indexPath = indexPath {
						   tableView.deleteRows(at: [indexPath], with: .fade)
					   }
				   case .update:
					   if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? NotesCell {
						   setupNotesCell(cell: cell, indexPath: indexPath)
					   }
				   case .move:
					   if let indexPath = indexPath {
						   tableView.deleteRows(at: [indexPath], with: .fade)
					   }

					   if let newIndexPath = newIndexPath {
						   tableView.insertRows(at: [newIndexPath], with: .fade)
					   }
			@unknown default:
				return
			}
			
		}

		func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
			tableView.endUpdates()
		}
}
