//
//  NotesListVC.swift
//  Notable
//
//  Created by Scott Kilbourn on 6/30/18.
//  Copyright © 2018 Scott Kilbourn. All rights reserved.
//
//  This is a sample of how to use NSFetchedResultsController to manage table data automatically.

import UIKit
import CoreData

class NotesListVC: UITableViewController, NSFetchedResultsControllerDelegate {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
    
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            print ("Error fetching data \(error)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (fetchedResultsController.sections?[section].numberOfObjects) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let note = fetchedResultsController.object(at: indexPath) as! Note
        
        cell.textLabel?.text = note.name
        
        return cell
    }

    // MARK: - nsFetchedResultsController Methods
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath)
                configureCell(cell: cell!, atIndexPath: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let record = fetchedResultsController.object(at: indexPath) as! Note
        
        // Update Cell
        if let name = record.name {
            cell.textLabel?.text = name
        }
        
    }
    
    // MARK: - Return Segues

    @IBAction func didAddItem(segue: UIStoryboardSegue) {
        let sourceSegue = segue.source as! NoteDetailVC
        
        //Add item to database
        let newNote = Note(context: context)
        
        newNote.name = sourceSegue.noteNameCtl.text!
        newNote.noteText = sourceSegue.noteTextCtl.text!
        fetchedResultsController.managedObjectContext.insert(newNote)
        saveData()
    }
    
    @IBAction func didEditItem(segue: UIStoryboardSegue) {
        let sourceSegue = segue.source as! NoteDetailVC
        
        //Edit item in database
        if let item = tableView.indexPathForSelectedRow {
            let note = fetchedResultsController.object(at: item) as! Note
            note.name = sourceSegue.noteNameCtl.text!
            note.noteText = sourceSegue.noteTextCtl.text!
            saveData()
        }
    }
    
    //MARK: - Data Methods
    func saveData() {
        do {
            try fetchedResultsController.managedObjectContext.save()
        }
        catch {
            print ("Error saving note \(error)")
        }
    }
    
    //MARK: - Call Detail Items
    @IBAction func addNewNote(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationSegue = segue.destination as! NoteDetailVC
        
        if (segue.identifier == "ShowNoteAdd") {
            destinationSegue.isEditing = false
            destinationSegue.noteName = ""
            destinationSegue.noteText = ""
        }
        else {
            if let sourceItem = tableView.indexPathForSelectedRow {
                let note = fetchedResultsController.object(at: sourceItem) as! Note
                destinationSegue.isEditing = true
                destinationSegue.noteName = note.name
                destinationSegue.noteText = note.noteText
            }
        }
    }
}

extension NotesListVC : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)

        fetchedResultsController.fetchRequest.predicate = predicate
        
        ReloadDataFromSearchBar()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchedResultsController.fetchRequest.predicate = nil
            
            ReloadDataFromSearchBar()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    private func ReloadDataFromSearchBar() {
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            print ("Error fetching results for search bar \(error)")
        }
        
        tableView.reloadData()
    }
}
