//
//  PanicMessagesViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 20/02/2023.
//

import UIKit
import FirebaseFirestore

class PanicMessagesViewController: UIViewController, UITableViewDataSource{
    var panicMessages = [String: Any]()
    @IBOutlet weak var panicMessagesTable: UITableView!
    let db = FirebaseFirestore.Firestore.firestore()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = panicMessagesTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        return cell
        
    }
    

    override func viewDidLoad() {
        panicMessagesTable.dataSource = self
        super.viewDidLoad()

        Utilities.getListFromSubcollection(user: Constants.currentUser.username, subcollectionName: "panicMessages", listKey: "sender") { panicMessages in
            self.panicMessages = panicMessages
            self.panicMessagesTable.reloadData()

        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
