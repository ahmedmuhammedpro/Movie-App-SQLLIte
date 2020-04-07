import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddProtocol {
    
    @IBOutlet weak var myTable: UITableView!
    let repo = Repository()
    var movies: Array<Movie>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTable.delegate = self
        myTable.dataSource = self
        
        movies = repo.fetchAllMovies()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let movie = movies![indexPath.row]
        let cell = myTable.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
        let url = URL(string: movie.url!)
        do {
            let imgData = try Data(contentsOf: url!)
            let img = UIImage(data: imgData)
            cell.movieImageView.image = img
            print("valid url \(url!.absoluteString)")
        } catch let error as NSError {
            print(url!.absoluteString)
            print(error)
        }
        
        cell.movieTitle.text = movie.title
        cell.movieRating.text = "\(movie.rating!)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            repo.deleteMovie(movie: movies![indexPath.row])
            movies?.remove(at: indexPath.row)
            myTable.reloadData()
        }
    }
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        let addView = storyboard?.instantiateViewController(identifier: "addView") as! AddViewController
        addView.addProtocol = self
        navigationController?.pushViewController(addView, animated: true)
    }
    
    func addMovie(movie: Movie) {
        repo.insertMovie(movie: movie)
        movies?.append(movie)
        myTable.reloadData()
    }
}

