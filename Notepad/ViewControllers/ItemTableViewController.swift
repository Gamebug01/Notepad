import UIKit
import RealmSwift

class ItemTableViewController: UITableViewController {

//    var itemArray = [Item]()
    var toDoItems : Results<Item>?
    var realm = try! Realm()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    // MARK: - TableView Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        if let item = toDoItems?[indexPath.row]  {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }
        else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
        
    }
    
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        toDoItems[indexPath.row].done = !toDoItems[indexPath.row].done
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            }catch {
                print(error)
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add ToDoey", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
//            let newItem = Item(context: self.context)
//            newItem.title = textField.text
//            newItem.done = false
//            newItem.parentCategory = self.selectedCategory
//            self.itemArray.append(newItem)
//            self.saveItems()
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print(error)
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Enter new ToDoey Item"
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
        
    }
    
//    func saveItems(items : Item) {
//
//        do {
//            try context.save()
//            try realm.write {
//                realm.add(items)
//            }
//        } catch  {
//            print(error)
//        }
//        tableView.reloadData()
//
//    }
    
//    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {
//
//        let categoryPredicate = NSPredicate(format: "parentCategory.title MATCHES %@", (selectedCategory?.title)!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        }
//        else {
//            request.predicate = categoryPredicate
//        }
//
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print(error)
//        }
//        tableView.reloadData()
//    }
    func loadItems() {
        
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
        
    }
}

//
extension ItemTableViewController : UISearchBarDelegate {

//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
////        let request : NSFetchRequest<Item> = Item.fetchRequest()
////
////        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
////        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
////
////        loadItems(with: request, predicate: predicate)
//
//        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!)
////            .sorted(byKeyPath: "dateCreated", ascending: true)
//
//    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS %@", searchBar.text!)
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
