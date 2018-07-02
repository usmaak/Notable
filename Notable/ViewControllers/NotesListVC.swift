//
//  NotesListVC.swift
//  Notable
//
//  Created by Scott Kilbourn on 6/30/18.
//  Copyright © 2018 Scott Kilbourn. All rights reserved.
//

import UIKit
import RealmSwift

class NotesListVC: UITableViewController {
    var notes: Results<Note>?
    var realm = try! Realm()
    
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
        return notes!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)

        cell.textLabel?.text = notes![indexPath.row].name
        
        return cell
    }

    // MARK: - Data Manipulation Methods
    func loadNotes() {
        notes = realm.objects(Note.self)
        tableView.reloadData()
    }
    
    func saveNotes(note: Note) {
        do {
            try realm.write {
                realm.add(note)
            }
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
        let newNote = Note()
        
        newNote.name = sourceSegue.noteNameCtl.text!
        newNote.noteText = sourceSegue.noteTextCtl.text!
        newNote.dateCreated = Date()
        newNote.dateLastUpdated = Date()
        
        saveNotes(note: newNote)
    }
    
    @IBAction func didEditItem(segue: UIStoryboardSegue) {
        let sourceSegue = segue.source as! NoteDetailVC
        
        //Edit item in database
        if let item = tableView.indexPathForSelectedRow?.row {
            do {
                try realm.write {
                    notes![item].name = sourceSegue.noteNameCtl.text!
                    notes![item].noteText = sourceSegue.noteTextCtl.text!
                    notes![item].dateLastUpdated = Date()
                }
            }
            catch {
                print ("Error saving update \(error)")
            }
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
        }
        else {
            let sourceItem = tableView.indexPathForSelectedRow?.row
            
            destinationSegue.isEditing = true
            destinationSegue.noteName = notes![sourceItem!].name
            destinationSegue.noteText = notes![sourceItem!].noteText
        }
    }
}

extension NotesListVC : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        notes = notes?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
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
