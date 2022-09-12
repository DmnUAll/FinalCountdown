//
//  EventInfoViewController.swift
//  FinalCountdown
//
//  Created by Илья Валито on 07.09.2022.
//

import UIKit

class EventInfoViewController: UITableViewController {
    
    @IBOutlet private weak var saveBarButton: UIBarButtonItem!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        nameTextField.delegate = self
        
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Event name (30 characters max)",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        descriptionTextField.attributedPlaceholder = NSAttributedString(
            string: "Event description",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        // Set the datePicker date to the current and time to 00:00
        datePicker.date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()
        
        // Dismiss the keyboard when user touches anywhere
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if nameTextField.text == "" {
            saveBarButton.isEnabled = false
        } else {
            saveBarButton.isEnabled = true
        }
    }
    
    // Deselect selected tableView cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if nameTextField.text != "" {
            guard let destinationVC = segue.destination as? MainViewController else { return }
            guard let name = nameTextField.text else { return }
            let description = descriptionTextField.text == "" ? "No Description" : descriptionTextField.text!
            destinationVC.appLogic.addEvent(name: name,
                                            description: description,
                                            date: datePicker.date)
        } else {
            showAlert(withTitle: "No event name given", andMessage: "You should enter an event name!")
            
        }
    }
    
    func fillUI(eventName: String?, eventDescription: String?, date: Date?) {
        DispatchQueue.main.async {
            self.nameTextField.text = eventName
            self.descriptionTextField.text = eventDescription == "No Description" ? "" : eventDescription!
            self.datePicker.date = date ?? Date()
        }
    }
    
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: false)
    }
    
    // Enables or disables the save button
    @IBAction func eventNameTextFieldChanged(_ sender: UITextField) {
  
        if sender.text != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    // Checking the date for right value to be setted
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        if sender.date < Date() {
            showAlert(withTitle: "Wrong date", andMessage: "Date must be in future!")
        }
    }
}

extension EventInfoViewController: UITextFieldDelegate {
    
    
    // Limit the nameTextField by the length of 30 characters.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if updatedText.count == 30 {
            showAlert(withTitle: "Maximum characters in name", andMessage: "You're reached the maximum of 30 characters for event name!")
        }
        return updatedText.count <= 30
    }
}
