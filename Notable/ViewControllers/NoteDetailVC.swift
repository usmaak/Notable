//
//  ViewController.swift
//  Notable
//
//  Created by Scott Kilbourn on 6/30/18.
//  Copyright © 2018 Scott Kilbourn. All rights reserved.
//

import UIKit

class NoteDetailVC: UIViewController {
    var noteName: String = ""
    var noteText: String = ""
    
    @IBOutlet weak var noteNameCtl: UITextField!
    @IBOutlet weak var noteTextCtl: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        noteNameCtl.text = noteName
        noteTextCtl.text = noteText
    }

    @IBAction func cancelOperation(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneWithNote(_ sender: UIBarButtonItem) {
        //Unwind Segues: AddItem, EditItem
        //First, check to make sure that there's a name
        if noteNameCtl.text == "" {
            let alert = UIAlertController(title: "Enter a note name", message: "A note name must be entered before continuing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got It!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            performSegue(withIdentifier: self.isEditing ? "EditItem" : "AddItem", sender: nil)
        }
    }
}

