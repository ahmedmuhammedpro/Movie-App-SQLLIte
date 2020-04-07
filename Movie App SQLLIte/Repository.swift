import Foundation
import SQLite3

class Repository {
    
    var db: OpaquePointer?
    
    init() {
        db = openDatabase()
        creatMoviesTable()
    }
    
    func openDatabase() -> OpaquePointer? {
        let fileURL: URL? = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("movies.db")
        
        let dbURL = fileURL?.path
        var db: OpaquePointer?
        guard let mdbURL = dbURL else {
            print("invalid path")
            return nil
        }
        
        if sqlite3_open(mdbURL, &db) == SQLITE_OK {
            print("connect to database scuccess")
            return db
        } else {
            print("connect to database failed")
            return nil
        }
    }
    
    func creatMoviesTable() {
        let queryStr = "create table Movies(url char(2000) not null, title char(350) primary key not null, rating double, releaseDate int, genre char(250));"
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, queryStr, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Movies table created")
            } else {
                print("cannot craete Movies table")
            }
        } else {
            print("invalid create statment")
        }
        
        sqlite3_finalize(createTableStatement)
    }
    
    func fetchAllMovies() -> Array<Movie> {
        let queryStr = "select * from Movies;"
        var selectStatement: OpaquePointer?
        var movies = Array<Movie>()
        if sqlite3_prepare_v2(db, queryStr, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                
                guard let queryResultCol0 = sqlite3_column_text(selectStatement, 0) else {
                    print("url result is nil")
                    return movies
                }
                let imgURL = String(cString: queryResultCol0)
                
                guard let queryResultCol1 = sqlite3_column_text(selectStatement, 1) else {
                    print("title is nil")
                    return movies
                }
                let title = String(cString: queryResultCol1)
                
                let rating = sqlite3_column_double(selectStatement, 2)
                
                let releaseDate = sqlite3_column_int(selectStatement, 3)
                
                guard let queryResultCol4 = sqlite3_column_text(selectStatement, 4) else {
                    print("genre is nil")
                    return movies
                }
                
                let genre = String(cString: queryResultCol4)
                
                let movie = Movie(url: imgURL, title: title, rating: rating, releaseDate: releaseDate, genre: genre)
                movies.append(movie)
            }
            
        } else {
            print("invald select statement")
        }
        
        sqlite3_finalize(selectStatement)
        
        return movies
    }
    
    func insertMovie(movie: Movie) {
        let queryStr = "insert into Movies(url, title, rating, releaseDate, genre) values(?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, queryStr, -1, &insertStatement, nil) == SQLITE_OK{
            
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            sqlite3_bind_text(insertStatement, 1, movie.url, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(insertStatement, 2, movie.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_double(insertStatement, 3, movie.rating!)
            sqlite3_bind_int(insertStatement, 4, movie.releaseDate!)
            sqlite3_bind_text(insertStatement, 5, movie.genre, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("movie inserted")
            } else {
                print("falied to insert movie")
            }
        } else {
            print("invald insert statement")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func updateMovie(oldMovieTitle: String, newMovie: Movie) {
        let queryStr = "update Movies set url = ?, title = ?, rating = ?, releaseDate = ?, genre = ? where title = ?;"
        
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, queryStr, -1, &updateStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(updateStatement, 1, newMovie.url, -1, nil)
            sqlite3_bind_text(updateStatement, 2, newMovie.title, -1, nil)
            sqlite3_bind_double(updateStatement, 3, newMovie.rating!)
            sqlite3_bind_int(updateStatement, 4, newMovie.releaseDate!)
            sqlite3_bind_text(updateStatement, 5, newMovie.genre, -1, nil)
            sqlite3_bind_text(updateStatement, 6, oldMovieTitle, -1, nil)
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("movie updated success")
            } else {
                print("movie updated failed")
            }
        } else {
            print("invald update statement")
        }
        
        sqlite3_finalize(updateStatement)
    }
    
    func deleteMovie(movie: Movie) {
        let queryStr = "delete from Movies where title = ?;"
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryStr, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, movie.title, -1, nil)
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("movie deleted success")
            } else {
                print("movie deleted failed")
            }
        } else {
            print("invalid delete statement")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func fetchOneMovie(title: String) -> Movie? {
        let queryStr = "select url, title, rating, releaseDate, genre\n from Movies where title = ?;"
        var selectStatement: OpaquePointer?
        
        let movie: Movie?
        
        if sqlite3_prepare_v2(db, queryStr, -1, &selectStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(selectStatement, 1, title, -1, nil)
            if sqlite3_step(selectStatement) == SQLITE_ROW {
                let url = sqlite3_column_text(selectStatement, 0)
                let mtitle = sqlite3_column_text(selectStatement, 1)
                let rating = sqlite3_column_double(selectStatement, 2)
                let releaseDate = sqlite3_column_int(selectStatement, 3)
                let genre = sqlite3_column_text(selectStatement, 4)
                
                movie = Movie(url: String(cString: url!), title: String(cString: mtitle!), rating: rating, releaseDate: releaseDate, genre: String(cString: genre!))
                
                print(movie!)
                return movie
            } else {
                print("failed to fetch one movie")
                return nil
            }
            
        } else {
            print("invaild select one movie statement")
            return nil
        }
    }
}
