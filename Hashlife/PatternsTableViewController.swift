//
//  PatternsTableTableViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/26/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class PatternsTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!

    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var patterns: [Pattern] = {
        return (try? PatternsTableViewController.context.fetch(Pattern.fetchRequest()))!
    }()
    
    var sections = [Character: [Int]]()
    var sectionKeys = [Character]()
    
    var filteredIndices = [Int]()
    var isSearching: Bool {
        return searchBar.text != nil && searchBar.text! != ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hides the search bar at initialization.
        self.tableView.contentOffset = CGPoint(x: 0, y: searchBar.bounds.height)
//        self.tableView.sectionIndexColor = UIColor.red
        
        patterns.enumerated().forEach {
            var char = $0.element.title!.first!
            char = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(char.description.uppercased()) ? char.description.uppercased().first! : "#"
            if sections.keys.contains(char) {
                sections[char]?.append($0.offset)
            } else {
                sections[char] = [$0.offset]
                sectionKeys.append(char)
            }
        }
        
        sectionKeys = sectionKeys.sorted(by: <)
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
        return isSearching ? 1 : sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredIndices.count : sections[sectionName(from: section)]!.count
    }
    
    


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "patternItemCell", for: indexPath) as! PatternTableViewCell
        let index = designatedIndex(indexPath)
        let pattern = patterns[index] //this might save some performance...
        cell.nameLabel?.text = pattern.title
        cell.authorLabel?.text = pattern.author

        //only show the rules that are different.
        let rule = pattern.rule == "~" ? "" : pattern.rule
        cell.ruleLabel?.text = rule
        return cell
    }

    private func designatedIndex(_ indexPath: IndexPath) -> Int {
        return isSearching ? filteredIndices[indexPath.row] : sections[sectionName(from: indexPath.section)]![indexPath.row]
    }
    
    private func sectionName(from index: Int) -> Character {
        return sectionKeys[index]
    }


//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return headers[section]
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            PatternsTableViewController.context.delete(patterns[indexPath.row] )
            patterns.remove(at: indexPath.row)
            do {
                try PatternsTableViewController.context.save()
            } catch {
                print("Failed to save changes to core data.")
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    public func add(_ pattern: Pattern, at indexPath: IndexPath) {
        self.patterns.insert(pattern, at: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    

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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isSearching ? "" : sectionName(from: section).description
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionKeys.map {$0.description}
    }
    
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let destination = segue.destination as? PatternViewerViewController,
              let indexPath = self.tableView.indexPathForSelectedRow else {
            return
        }
        let index = designatedIndex(indexPath)
        destination.pattern = patterns[index]
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredIndices = self.patterns.map{$0.title}.enumerated().map { (i, name) in
            if let title = patterns[i].title {
                if title.lowercased().contains(searchText.lowercased()) {
                    return i
                }
            }
            return -1
        }.filter {
            $0 != -1
        }
        print(String(describing: filteredIndices))
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}
