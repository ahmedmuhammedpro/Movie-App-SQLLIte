import Foundation

class Movie {
    
    var url: String?
    var title: String?
    var rating: Double?
    var releaseDate: Int32?
    var genre: String?
    
    init() {
    }
    
    init(url: String, title: String, rating: Double, releaseDate: Int32, genre: String) {
        self.url = url
        self.title = title
        self.rating = rating
        self.releaseDate = releaseDate
        self.genre = genre
    }
}
