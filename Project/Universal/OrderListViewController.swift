//
//  OrderListViewController.swift
//  Universal
//
//  Created by suraj medar on 05/08/20.
//  Copyright © 2020 VRCODEHUB. All rights reserved.
//

import UIKit

struct OrderInfo {
    var status : String!
    var date : String!
    var orderNumber : String!
    var currencySymbol : String!
    var orderList = [OrderListInfo]()
}

struct OrderListInfo {
    var id : String!
    var name : String!
    var productId : String!
    var price : String!
    var variationId : String!
    var quantity : String!
}

class OrderListTableViewCell: UITableViewCell {
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
}

class OrderListViewController: UIViewController {
    @IBOutlet weak var orderListTableView: UITableView!
    var orders = [OrderInfo]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getOrderList(userId : UserDefaults.standard.string(forKey: "userId") ?? "")
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

extension OrderListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderListTableViewCell
        let data = orders[indexPath.row]
        
        cell.statusBtn.setTitle(data.status, for: .normal)
        cell.titleLbl.text = "\(data.orderNumber! ) \(data.orderList[0].name ?? "")"
        cell.amountLbl.text = "\(data.currencySymbol!) \(data.orderList[0].price == "" ? "0" : data.orderList[0].price ?? "0")"
        cell.dateLbl.text = data.date
        
        return cell
    }
    
    
}

extension OrderListViewController {
    func getOrderList(userId : String) {
        let userId = UserDefaults.standard.string(forKey: "userId")
        let url = "https://yourgastroapp.com/wp-json/wc/v3/orders?customer=\(userId ?? "")&consumer_key=ck_d8dba8a11c68b9cfd3f99b837875eae200217fcf&consumer_secret=cs_896618f0b8b4fc765ef2b590da5b97e7c43fa9e2"
        let semaphore = DispatchSemaphore (value: 0)
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue("Basic Og==", forHTTPHeaderField: "Authorization")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.addValue("wordpress_test_cookie=WP+Cookie+check", forHTTPHeaderField: "Cookie")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let urlContent = data {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    if jsonResult == nil {
                        self.alertMessage(title: "", message: "Data not available")
                    } else {
                        self.orders = self.getOrderData(result:(jsonResult as! NSArray))
                        DispatchQueue.main.async {
                            print(self.orders.count)
                            self.orderListTableView.reloadData()
                        }
                    }
                } catch {
                    OperationQueue.main.addOperation {
                        self.alertMessage(title: "", message: "Network error!")
                    }
                }
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    func getOrderData(result :NSArray) -> [OrderInfo] {
        var orders = [OrderInfo]()
        for item in result {
            var orderInfo = OrderInfo()
            var orderList = [OrderListInfo]()
            orderInfo.status = (item as! NSDictionary)["status"] as? String ?? ""
            orderInfo.date = (item as! NSDictionary)["date_created"] as? String ?? ""
            orderInfo.orderNumber = (item as! NSDictionary)["number"] as? String ?? ""
            orderInfo.currencySymbol = (item as! NSDictionary)["currency_symbol"] as? String ?? ""
            guard let records = (item as! NSDictionary)["line_items"] as? [AnyObject] else { return [] }
            for item in records {
                var orderListInfo = OrderListInfo()
                orderListInfo.id = item["id"] as? String ?? ""
                orderListInfo.name = item["name"] as? String ?? ""
                orderListInfo.price = item["price"] as? String ?? ""
                orderListInfo.productId = item["product_id"] as? String ?? ""
                orderListInfo.quantity = item["quantity"] as? String ?? ""
                orderListInfo.variationId = item["variation_id"] as? String ?? ""
                
                orderList.append(orderListInfo)
            }
            orderInfo.orderList = orderList
            orders.append(orderInfo)
        }
        
        return orders
    }
}


