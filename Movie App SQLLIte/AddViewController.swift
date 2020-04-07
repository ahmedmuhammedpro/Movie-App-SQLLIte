import UIKit

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var ratingTF: UITextField!
    @IBOutlet weak var releaseDateTF: UITextField!
    @IBOutlet weak var genreTF: UITextField!
    
    var addProtocol: AddProtocol?
    var imgURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(title: "done", style: .plain, target: self, action: #selector(self.done(_:)))
        navigationItem.setRightBarButton(doneButton, animated: true)
    }
    
    @objc func done(_ sender: UIBarButtonItem) {
        let mtitle = titleTF.text!
        let rating = Double(ratingTF.text!) ?? 0.0
        let releaseDate = Int32(releaseDateTF.text!) ?? 0
        let genre = genreTF.text!
        
        let movie = Movie(url: imgURL!, title: mtitle, rating: rating, releaseDate: releaseDate, genre: genre)
        addProtocol?.addMovie(movie: movie)
        navigationController?.popViewController(animated: true)
        
    }

    @IBAction func pickImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "ERROR", message: "sorry your device doesn't support this media type", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mImgURL = info[.imageURL] as? URL {
            imgURL = mImgURL.absoluteString
            print(imgURL!)
        }
        
        if let img = info[.originalImage] as? UIImage {
            pickedImageView.image = img
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
