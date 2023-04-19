//
//  UserDefaultManager.swift
//  CommonTemplate
//
//  Created by 이동희 on 2023/04/19.
//

import UIKit

struct UserDefaultManager {
    enum Keys: String {
        case doNotShowPopupToday = "doNotShowPopupToday"
        case splashImage = "splashImage"
    }
    
    static var shared = UserDefaultManager()
    
    /// Example
    @UserDefault(key: Keys.doNotShowPopupToday.rawValue, defaultValue: nil)
    static var doNotShowPopupToday: Date?
    
    /// Example Function
    /// 오늘 하루 안보기
    /// 이 함수는 ViewModel / UseCase 에서 사용
    func checkCanShow() -> Bool {
        var doNotShowPopupToday: Bool = false
        if let doNotShowPopupTodayDate = UserDefaultManager.doNotShowPopupToday {
            let timeInterval = abs(doNotShowPopupTodayDate.distance(to: Date()))
            doNotShowPopupToday = timeInterval < 60 * 60 * 24
        }
        return doNotShowPopupToday
    }
    
    /// Nullable Example
    @UserDefaultNullable(key: Keys.splashImage.rawValue)
    static var splashImage: Data?
    
    /// Example Function
    /// splash Image 저장용도
    /// ViewModel / UseCase 에서 사용
    func checkHaveSplash() {
        var onLoadImage: ((UIImage?) -> Void)?
        if let loadedBefore = UserDefaultManager.splashImage {
            guard let toImage = UIImage(data: loadedBefore) else { return }
            onLoadImage?(toImage)
            Task {
                // 다음 스플래시 이미지를 서버에서 받아온 뒤 저장
                // save(image: await loadImageFromServer())
            }
        } else { // 저장된 스플래시 이미지가 없는 경우
            Task {
                // let nextImage = await loadImageFromServer()
                // onLoadImage?(nextImage)
                // save(image: nextImage)
            }
        }
    }
    
    private func save(image: UIImage?) {
        guard let image = image else { return }
        let pngImage = image.pngData()
        UserDefaultManager.splashImage = pngImage
    }
    
}

extension UserDefaultManager {
    @propertyWrapper
    struct UserDefault<Value> {
        let key: String
        let defaultValue: Value
        
        var wrappedValue: Value {
            get {
                return UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
            }
            set {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
    
    @propertyWrapper
    struct UserDefaultNullable<Value> {
        let key: String
        
        var wrappedValue: Value? {
            get {
                return UserDefaults.standard.object(forKey: key) as? Value
            }
            
            set {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
}
