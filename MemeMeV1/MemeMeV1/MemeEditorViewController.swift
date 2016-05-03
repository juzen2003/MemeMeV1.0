//
//  MemeEditorViewController.swift
//  MemeMeV1
//
//  Created by Yu-Jen Chang on 3/23/16.
//  Copyright © 2016 Yu-Jen Chang. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    let textFieldDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialView()
    }
    
    // initial view 
    func setInitialView() {
        textFieldInitialization(topTextField, initString: "TOP")
        textFieldInitialization(bottomTextField, initString: "BOTTOM")
        shareButton.enabled = false
        imagePickerView.image = nil
    }
    
    func textFieldInitialization(textField: UITextField!, initString: String) {
        textField.delegate = textFieldDelegate
        // set text attributes
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -5.0
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = initString
        textField.textAlignment = .Center
        
        textField.backgroundColor = UIColor.clearColor()
        textField.borderStyle = UITextBorderStyle.None
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // check if camera is avaiable on the device
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        // sign up to to be notified when keyboard appears
        subscribeKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // unsubscribe keyboard notification
        unsubscribeFromKeyboardNotifications()
    }
    
    // hide the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // album button
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        presentImagePickerView(.PhotoLibrary)
    }
    
    // camera button
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        presentImagePickerView(.Camera)
    }
    
    // present image picker view
    func presentImagePickerView(source: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        presentViewController(imagePickerController, animated: true, completion: nil)
        imagePickerController.sourceType = source
    }
    
    // dimiss image picker view when user select a still image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // display the original image to UIImageView box
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .ScaleAspectFit
            shareButton.enabled = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // dimiss image picker view when user hit cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // move the view when textfield is covered by keyboard
    func keyboardWillShow(notification: NSNotification) {
        // aviod view moving twice when user click on both text fields w/o typing
        if view.frame.origin.y == 0 && bottomTextField.isFirstResponder() {
            view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    
    // move the view frame down a distance equal to keyboard height
    func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y < 0 && bottomTextField.isFirstResponder() {
            view.frame.origin.y = 0
        }
    }
    
    // get keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // observe keyboard notifications
    func subscribeKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // remove keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // share button
    @IBAction func share(sender: AnyObject) {
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentViewController(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = {
            (activityType, completed: Bool, returnedItems: [AnyObject]?, error: NSError? ) in
            // return if cancelled
            if (!completed) {
                return
            } else {
                self.save(image)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // create Meme object
    func save(memedImage: UIImage) {
        //let meme = Meme(text: textField.text!, image: imageView.image, memedImage: memedImage)
        _ = Meme(topText: topTextField.text, bottomText: bottomTextField.text, image: imagePickerView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        // hide toolbar and navbar
        navigationController?.navigationBar.hidden = true
        toolBar.hidden = true
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // show toolbar and navbar
        navigationController?.navigationBar.hidden = false
        toolBar.hidden = false
        
        return memedImage
    }
    
    // canecel button, go back to original view
    @IBAction func cancelAndReturnToOriginalView(sender: AnyObject) {
        setInitialView()
    }
    
}

