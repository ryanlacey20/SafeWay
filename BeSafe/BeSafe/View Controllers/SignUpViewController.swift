//
//  ViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 07/11/2022.
//

import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet var firstNameTextField: UITextField!

    @IBOutlet var lastNameTextField: UITextField!

    @IBOutlet var emailTextField: UITextField!

    @IBOutlet var usernameTextField: UITextField!

    @IBOutlet var passwordTextField: UITextField!

    @IBOutlet var passwordConfirmationTextField: UITextField!

    @IBOutlet var errorLabel: UILabel!

    func isValid() -> String? {
        // Ensure all fields are full
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordConfirmationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields"
        }
        
        if !Utilities.isEmailValid(emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)){
            return "email is not correctly formed"
        }
        
        if !Utilities.isUsernameValid(usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)){
            return "username must not contain blank spaces"
        }
        
        if !Utilities.isNameValid(firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) || !Utilities.isNameValid(lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return "first and last names may only contain letters and blank spaces"
        }


        // Check password is secure enough
        let trimmedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPassword != passwordConfirmationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            return "passwords do not match"
        }
        if !Utilities.isPasswordValid(trimmedPassword) {
            return "Please ensure password contains: 8 charecters, a number and a special character"
        }
        return nil
    }

    @IBAction func signUpTapped(sender _: Any) {
        // Validate inputted information
        let error = isValid()
        if error != nil {
            showErrorMessage(message: error!)
            view.endEditing(true)
        } else {
            // trimmed information
            // TODO: change uses of "surname" to "lastName" for constistency
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            let db = FirebaseFirestore.Firestore.firestore()
            let docRef = db.collection("users").document(username)
            docRef.getDocument { document, error in
                print("document", document!.exists, username)
                // checking if the username is taken (the username is used as the document name)
                if (document!.exists){ self.showErrorMessage(message: "Username already exists")}  else {
                    // Create user once validated
                    Auth.auth().createUser(withEmail: email, password: password) { result, err in
                        if err != nil {
                            // An error occured creating a user
                            self.showErrorMessage(message: "An error occured during sign up \(err!.localizedDescription)")
                        } else {
                            // succesful user creation
                            let db = FirebaseFirestore.Firestore.firestore()

                            let changeRequest = result!.user.createProfileChangeRequest()
                            changeRequest.displayName = username

                            changeRequest.commitChanges { error in
                                if let error = error {
                                    // Handle the error
                                    print("Error updating display name: \(error.localizedDescription)")
                                } else {
                                    // Display name was updated successfully
                                    print("Display name was updated successfully")
                                }
                            }
                            // set data in the database
                            db.collection("users").document(username).setData(["first_name": firstName, "last_name": lastName, "username": username, "checkedIn": false, "uid": result!.user.uid, "following": [], "sosContacts": [], "isSharingLocation": false]) { error in
                                if error != nil {
                                    // TODO: reconsider how this is handled
                                    self.showErrorMessage(message: "User has been created, error saving first name and last name")
                                } else {
                                    db.collection("users").document(username).collection("checkInRequestsSent").addDocument(data: [:])
                                    db.collection("users").document(username).collection("panicMessages").addDocument(data: [:]) { error in
                                        if let error = error {
                                            print("error creating collection panicMessages \(error)")
                                        }
                                    }
                                    
                                        self.goToWelcomeScreen()
                                    
                                }
                            }
                        }
                    }
                }
            }

            // Move to the app homescreen
        }
    }

    func showErrorMessage(message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }

    func setUpElements() {
        errorLabel.alpha = 0
    }

    func goToWelcomeScreen() {
        let welcomeViewController = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
        view.window?.rootViewController = welcomeViewController
        view.window?.makeKeyAndVisible()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            // User is signed in.
        } else {
            // No user is signed in.
        }
        setUpElements()
    }
}
