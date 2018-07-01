//
//  NotesListVC.swift
//  Notable
//
//  Created by Scott Kilbourn on 6/30/18.
//  Copyright © 2018 Scott Kilbourn. All rights reserved.
//

import UIKit
import CoreData

class NotesListVC: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotes()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)

        cell.textLabel?.text = notes[indexPath.row].name
        
        return cell
    }

    // MARK: - Data Manipulation Methods
    func loadNotes(with request: NSFetchRequest<Note> = Note.fetchRequest()) {
        do {
            notes = try context.fetch(request)
        }
        catch {
            print ("Error fetching notes \(error)")
        }
        
        tableView.reloadData()
    }
    
    func saveNotes() {
        do {
            try context.save()
        }
        catch {
            print ("Error saving notes \(error)")
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Return Segues
    @IBAction func didAddItem(segue: UIStoryboardSegue) {
        let sourceSegue = segue.source as! NoteDetailVC
        
        //Add item to database
        let newNote = Note(context: context)
        
        newNote.name = sourceSegue.noteNameCtl.text!
        newNote.noteText = sourceSegue.noteTextCtl.text!
        notes.append(newNote)
        
        saveNotes()
    }
    
    @IBAction func didEditItem(segue: UIStoryboardSegue) {
        let sourceSegue = segue.source as! NoteDetailVC
        
        //Edit item in database
        if let item = tableView.indexPathForSelectedRow?.row {
            notes[item].name = sourceSegue.noteNameCtl.text!
            notes[item].noteText = sourceSegue.noteTextCtl.text!
            
            saveNotes()
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
            let sourceItem = tableView.indexPathForSelectedRow?.row
            
            destinationSegue.isEditing = true
            destinationSegue.noteName = notes[sourceItem!].name
            destinationSegue.noteText = notes[sourceItem!].noteText
        }
    }
}

extension NotesListVC : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        loadNotes(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadNotes()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
