//
//  CoreDataPopulator.swift
//  Hashlife
//
//  Created by Jiachen Ren on 8/1/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//interpret the rle files and populate them into core data.
class CoreDataPopulator {
    static var delegate: CoreDataPopulatorDelegate?
    
    static var fileNamesPlist: Dictionary<String, Array<Any>> = {
        let path = Bundle.main.path(forResource: "names", ofType: "plist", inDirectory: nil)
        let url = URL(fileURLWithPath: path!)
        let dictionary = NSDictionary(contentsOf: url)! as! Dictionary<String, Array<Any>>
        return dictionary
    }()
    
    static var headers: [String] = {
        return fileNamesPlist["headers"]! as! [String]
    }()
    
    static var items: Array<Dictionary<String, String>> = {
        return fileNamesPlist["elem"] as! Array<Dictionary<String, String>>
    }()
    
    static var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static var numFiles: Int = 0
    static var curFile: Int = 0
    
    public static func populate(startIndex: Int) {
        if (startIndex == 0) {
            emptyExistingEntity("Pattern")
        }
        
        let names = items.map {$0["name"]!}
        let rules = items.map {$0["rule"]!}
        let filenames = items.map {$0["filename"]!}
        let extensions = items.map {$0["ext"]!}
        let authors = items.map {dict -> String in
            let extracted = dict["author"]!
            return extracted == "null" ? "Unknown" : extracted
        }
        
        filenames.enumerated().filter{$0.0 >= startIndex}.forEach{(i: Int, filename: String) in
            let contentOfFile = Utils.loadFile(name: filename, extension: extensions[i])!
            let mgr = CoordinateManager(UniverseSimulator.interpret(rle: contentOfFile))
            mgr.updateCoordinates()
            
            let pattern = Pattern(context: context) // Link Pattern & Context
            pattern.xCoordinates = mgr.coordinates.map{$0.x} as NSObject
            pattern.yCoordinates = mgr.coordinates.map{$0.y} as NSObject
            pattern.title = names[i]
            pattern.author = authors[i]
            pattern.rule = rules[i]
            pattern.overview = retrieveOverview(contentOfFile)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            saveToUserDefault(obj: i as Int, key: "ConstructedIntex") //if interrupted, this is where it is going to start next time the app starts.
            delegate?.didUpdate(currentFile: i, numberOfFiles: filenames.count)
//            print("Constructing database... processing \(i) of \(filenames.count)")
        }
        delegate?.didFinishDataBaseConstruction()
        print("Finished!")
    }
    
    public static func retrieveOverview(_ lines: String) -> String {
        var overview: String = ""
        lines.components(separatedBy: "\n").forEach { line in
            if line.hasPrefix("#C") {
                let index = line.index(after: line.startIndex)
                if let readIndex = line.index(index, offsetBy: 2, limitedBy: line.endIndex) {
                    if line.contains("http") || line.contains("www") {
                        overview += "\nSource: "
                    }
                    overview += line.substring(from: readIndex).replacingOccurrences(of: "\r", with: "\n")
                }
            }
        }
        return overview.replacingOccurrences(of: "\n", with: " ")
    }
    
    public static func emptyExistingEntity(_ entity: String) {
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try context.execute(request)
        } catch {
            print("core data dumping failed.")
        }
    }
    
}

public protocol CoreDataPopulatorDelegate {
    func didFinishDataBaseConstruction()
    func didUpdate(currentFile: Int, numberOfFiles: Int)
}
