//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
  
    //TODO: LISTA EJEMPLO
    //MARK: LISTA EJEMPLO MARCA
    
    // Declare instance variables here
    // Se crea un array con la lista de mesnajes, donde se almacenarán
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        // se debe declarar eso para que el delegate y el datasource se deplieguen en la tabla
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        // tapgesture se usa para detectar cualquier actividad
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        // agrega el gesto de reconocimiento para el mensaje de tabla
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        // se registrar el objeto creado CustomMessageCell en la Tabla, para que pueda ser usado
        // El diseño esta en elarchvio .xib
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        // Modificar estilos de la tabla de mensajes
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    // ESte metodo se llama por cada uno de las celdas que se despliega en la tabla
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Metodo para reutilizar una celda dentro del viewcontorller.
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        //let messageArray = ["MENSAJE 1","MENSAJE 2","MENSAJE 3 - APRENDIENDO IOS PARA PODER DESARROLLAR APLICACIONES PARA TODOS LOS NIÑOS IOS"]
        //cell.messageBody.text = messageArray[indexPath.row]
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            cell.messageBackground.backgroundColor = UIColor.flatYellow()
            cell.avatarImageView.backgroundColor = UIColor.flatYellow()
        } else {
            cell.messageBackground.backgroundColor = UIColor.flatCoffee()
            cell.avatarImageView.backgroundColor = UIColor.flatCoffee()
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    // cuantas seldas quiere en total y cuantas celdas quiere desplegar
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    // Metodo que permite recalcular el alto de los mensajes y no se corten
    func configureTableView () {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    // metodo que se ejecuta antes de que la gente empiece a editar en el campo
    // se ejecuta automaticamente
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308 // aumenta la vista a 308
            self.view.layoutIfNeeded() // Actualiza la vista si es neceario
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    // metodo que se ejeucta una vez las personas terminen de editar
    // No se ejecuta automaticamente
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    // Metodo que se ejecuta cuando presiona el boton enviar mensaje
    @IBAction func sendPressed(_ sender: AnyObject) {
        // Ejecutar el metodo fin de edicion, para que gesture se ejecute
        messageTextfield.endEditing(true)
        // deshabilitar el inputText y el boton para que no envie mas de uno
        sendButton.isEnabled = false
        messageTextfield.isEnabled = false
        //TODO: Send the message to Firebase and save it in our database
        // Crear una referencia a Firebase a la seccion "Messages"
        let messageBd = Database.database().reference().child("Message")
        // Crear el mensaje, como un diccionario
        let messageDirectory = ["Sender": Auth.auth().currentUser?.email, "Messagebody": messageTextfield.text!]
        // con la referencia a la base de datos salvar el mensaje creado
        // se usa un metodo para crear un id unico de mesaje
        messageBd.childByAutoId().setValue(messageDirectory){
            (error, reference) in
            
            if error != nil {
                print (error!)
            }else{
                
                self.sendButton.isEnabled = true
                self.messageTextfield.isEnabled = true
                self.messageTextfield.text = ""
            }
            
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages(){
        SVProgressHUD.show()
        // Referencia a base dea dtos y hijo Messages
        let messageBd = Database.database().reference().child("Message")
        // clouser que se ejecuta cada vez que se agregue un hijo a la seccion Message
        messageBd.observe(.childAdded) { (snapshot) in
            // hace un parcer al snapshot
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            print(snapshotValue)
            // recupera atributos creados del mensaje de firebase
            let body = snapshotValue["Messagebody"]!
            let sender = snapshotValue["Sender"]!
            // Crear un nuevo objeto de tipo Message
            let messageObj = Message()
            messageObj.messageBody = body
            messageObj.sender = sender
            // Agregar el mensaje a la array ya creado
            self.messageArray.append(messageObj)
            // Actualizar la vista de la app
            self.configureTableView()
            // hacer refresh sobre el datasource
            self.messageTableView.reloadData()
            
            SVProgressHUD.dismiss()
            
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch  {
            print ("Error signOut")
        }
        
    }
    


}
