//
//  NetworkTableViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/30/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

let patternsFromVan = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"

class NetworkTableViewController: UITableViewController {

    var titles: [String]?
    var coordinateMgrs = [CoordinateManager]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetcher = Fetcher()
        fetcher.fetch(from: URL(string: patternsFromVan)!) { (status) in
            switch status {
            case .failure(let str): print(str ?? "no err msg but failed")
            case .success(let data):
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                    return print("failed to parse json")
                }
                self.titles = [String]()
                (json as! NSArray).forEach{obj in
                    let dict = obj as! NSDictionary
                    self.titles?.append(dict["title"] as! String)
                    let coordinates: [Coordinate] = (dict["contents"] as! [[Int]]).map{(x: $0[0], y: $0[1])}
                    let manager = CoordinateManager(coordinates)
                    manager.updateCoordinates() //prepares the coordinate for my infinite game of life universe!
                    self.coordinateMgrs.append(manager)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titles?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "simplifiedPatternItemCell", for: indexPath)
        if let titles = self.titles {
            cell.textLabel?.text = titles[indexPath.row]
        } else {
            cell.textLabel?.text = "Retrieving patterns..."
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let patternViewer = segue.destination as? PatternViewerViewController {
            let index = tableView.indexPathForSelectedRow!.row
            patternViewer.mgr = self.coordinateMgrs[index]
            patternViewer.patternTitle = self.titles?[index]
            patternViewer.author = "Possibly Van himself... just kidding."
            patternViewer.patternDescription = "Some very simple patterns from: " + patternsFromVan
        }
    }
    

}
