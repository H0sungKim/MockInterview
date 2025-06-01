//
//  SettingViewController.swift
//  MockInterview
//
//  Created by 김호성 on 2025.05.30.
//

import UIKit

class SettingViewController: UIViewController {
    
    private var url: URL?
    @IBOutlet weak var pdfButton: UIButton!
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var styleSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
    }

    @IBAction func onClickPDF(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }
    
    @IBAction func onClickEnter(_ sender: Any) {
        let viewController: InterviewViewController = InterviewViewController.create()
        viewController.configure(style: Int(styleSlider.value), job: jobTextField.text ?? "", pdfURL: url!)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SettingViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        url = urls.first
        pdfButton.setTitle(urls.first?.lastPathComponent, for: .normal)
        print(url)
//        pdfView.document = PDFDocument(url: urls.first!)
    }
}

