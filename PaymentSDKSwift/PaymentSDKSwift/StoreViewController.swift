//
//  StoreViewController.swift
//  PaymentSDKSwift
//
//  Created by Gustavo Sotelo on 08/09/17.
//  Copyright © 2017 Payment. All rights reserved.
//

import UIKit
import PaymentSDK



class StoreViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableV: UITableView!
    
    var PaymentRequestParameters:PaymentDebitParameters?
    
    var selectedCard:PaymentCard?
    
    var productTitles = ["Pozole Blanco", "Latte"]
    
    var productPrices = [80.0, 50.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableV.tableFooterView = UITableView()
        
        self.activityIndicator.hidesWhenStopped = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func placeOrder(_ sender: Any) {
        if self.selectedCard  != nil
        {
            self.activityIndicator.startAnimating()
            var total = 0.0
            for p in self.productPrices
            {
                total = p + total
            }
            let uuid = UUID().uuidString  // replace with your own order id
            let sessionId = PaymentSDKClient.getSecureSessionId()
            MyBackendLib.debitCard(uid: UserModel.uid, cardToken: (self.selectedCard?.token)!, sessionId: sessionId, devReference: uuid, amount: total, description: "compra", callback: { (error, trx) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    if let transaction = trx
                    {
                        
                        let alertC = UIAlertController(title: "Success", message: "transaction_id:\(String(describing: transaction.transactionId!)), status:\(String(describing: transaction.status!)), authcode:\(String(describing: transaction.authorizationCode)), carrier_code:\(String(describing: transaction.carrierCode))", preferredStyle: UIAlertController.Style.alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alertaction) in
                            
                        })
                        let defaultAction2 = UIAlertAction(title: "VERIFY", style: .default, handler: { (alertaction) in
                            let alertController = UIAlertController(title: "Verificar ", message: "Especifica el valor: Monto o valor", preferredStyle: .alert)
                            alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
                                textField.placeholder = "Valor"
                            })
                            let verifyActionAmount = UIAlertAction(title: "Verificar por Monto", style: .default, handler: { (alertaction) in
                                MyBackendLib.verifyTrx(uid: UserModel.uid, transactionId: transaction.transactionId!, type: 0, value: (alertController.textFields?[0].text!)!, callback: { (error, verified) in
                                    
                                    if verified
                                    {
                                        let alertC = UIAlertController(title: "Vefificada", message: "trx:"+(transaction.transactionId!), preferredStyle: UIAlertController.Style.alert)
                                        
                                        let defaultAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                                        })
                                        alertC.addAction(defaultAction)
                                        self.present(alertC, animated: true
                                            , completion: {
                                                
                                        })
                                    }
                                    else
                                    {
                                        let alertC = UIAlertController(title: "Error en Verificación", message: error?.description, preferredStyle: UIAlertController.Style.alert)
                                        
                                        let defaultAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                                        })
                                        alertC.addAction(defaultAction)
                                        self.present(alertC, animated: true
                                            , completion: {
                                                
                                        })
                                    }
                                    
                                })
                            })
                            let verifyActionAmount2 = UIAlertAction(title: "Verificar por Código", style: .default, handler: { (alertaction) in
                                MyBackendLib.verifyTrx(uid: UserModel.uid, transactionId: transaction.transactionId!, type: 1, value: (alertController.textFields?[0].text!)!, callback: { (error, verified) in
                                    
                                    if verified
                                    {
                                        let alertC = UIAlertController(title: "Vefificada", message: "trx:"+(transaction.transactionId!), preferredStyle: UIAlertController.Style.alert)
                                        
                                        let defaultAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                                        })
                                        alertC.addAction(defaultAction)
                                        self.present(alertC, animated: true
                                            , completion: {
                                                
                                        })
                                    }
                                    else
                                    {
                                        let alertC = UIAlertController(title: "Error en Verificación", message: error?.description, preferredStyle: UIAlertController.Style.alert)
                                        
                                        let defaultAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                                        })
                                        alertC.addAction(defaultAction)
                                        self.present(alertC, animated: true
                                            , completion: {
                                                
                                        })
                                    }
                                    
                                })
                            })
                            let verifyClose = UIAlertAction(title: "Cancelar", style: .cancel, handler: { (alertaction) in
                                
                            })
                            alertController.addAction(verifyActionAmount)
                            alertController.addAction(verifyActionAmount2)
                            alertController.addAction(verifyClose)
                            self.present(alertController, animated: true
                                , completion: {
                                    
                            })
                        })

                        alertC.addAction(defaultAction)
                        alertC.addAction(defaultAction2)
                        self.present(alertC, animated: true)
                    }
                }
                
                
            })
        }
    }

}
extension StoreViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1
        {
                let alert = UIAlertController(title: "UID", message: "Please TYPE UID", preferredStyle: .alert)
                
                alert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "Enter UID"
                })
                let alertaction = UIAlertAction(title: "OK", style: .default) { (action) in
                    let firstTextField = alert.textFields![0] as UITextField
                    UserModel.uid = firstTextField.text ?? UserModel.uid
                    self.performSegue(withIdentifier: "listViewController", sender: self)
                }
                alert.addAction(alertaction)
            self.present(alert, animated: true)
            
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
          return productPrices.count
        }
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell")
            
            cell?.textLabel?.text = self.productTitles[indexPath.row]
            cell?.detailTextLabel?.text = String(format: "$%.02f", self.productPrices[indexPath.row])
            return cell!
        }
        else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell")
            
            if selectedCard != nil
            {
                cell?.detailTextLabel?.text = "***" + (self.selectedCard?.termination!)!
                cell?.imageView?.image = self.selectedCard?.getCardTypeAsset()
            }
            else
            {
                cell?.textLabel?.text = "Forma de Pago"
                cell?.detailTextLabel?.text = "Selecciona"
            }
            return cell!
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "totalCell")
            
            var total = 0.0
            for p in self.productPrices
            {
                total = p + total
            }
            cell?.detailTextLabel?.text = String(format: "$%.02f", total)
            return cell!
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "listViewController"
        {
            let lVC = segue.destination as! ListCardsTableViewController
            lVC.cardSelectedDelegate = self
        }
        
    }
    
}



extension StoreViewController:CardSelectedDelegate
{
    func cardSelected(card: PaymentCard?) {
        self.selectedCard = card
        self.tableV.reloadData()
    }
}
