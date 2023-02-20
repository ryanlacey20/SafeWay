//
//  ViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 07/11/2022.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseFirestore


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField : UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
   
    func isValid()->String?{
        //Ensure all fields are full
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordConfirmationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
          return "Please fill in all fields"
        }
        
        //Check password is secure enough
        let trimmedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if !Utilities.isPasswordValid(trimmedPassword) {
            return "Please ensure password contains: 8 charecters, a number and a character"
        }
        return nil
    }
    
    
    @IBAction func signUpTapped( sender: Any) {
        //Validate inputted information
        let error = isValid()
        if error != nil {
            showErrorMessage(message: error!)
            self.view.endEditing(true)
        }else{
            //trimmed information
            //TODO change uses of "surname" to "lastName" for constistency
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let db = FirebaseFirestore.Firestore.firestore()
            let docRef = db.collection("collection").document(username)
            docRef.getDocument { (document, error) in
                //checking if the username is taken (the username is used as the document name)
                if ((document?.exists) != nil) {
                        //Create user once validated
                        Auth.auth().createUser(withEmail: email, password: password ){(result, err) in
                        if (err != nil) {
                            //An error occured creating a user
                            self.showErrorMessage(message: "An error occured during sign up, please try again")
                        }else{
                            //succesful user creation
                            let db = FirebaseFirestore.Firestore.firestore()
                            db.collection("users").document(username).setData(["first_name": firstName, "last_name": lastName, "username": username, "uid": result!.user.uid, "following": []]) { (error) in
                                if error != nil{
                                    //TODO reconsider how this is handled
                                    self.showErrorMessage(message: "User has been created, error saving first name and last name")
                                }
                            }

                            self.goToWelcomeScreen()
                            
                        }
                    }
                }
                   else {
                       self.showErrorMessage(message: "Username taken please try another")
                  }
            }

            //Move to the app homescreen
        }
    }
    func showErrorMessage( message: String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func setUpElements(){
        errorLabel.alpha = 0;
    }
    
    func goToWelcomeScreen(){
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


