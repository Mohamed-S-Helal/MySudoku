//
//  vc2.swift
//  MySudoku
//
//  Created by MSalah on 11/4/20.
//  Copyright © 2020 MSalah. All rights reserved.
//

import UIKit
import SQLite

class vc2 : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    var level = "Easy"
    var A = Array(repeating: 0, count: 81)
    var B = Array(repeating: 0, count: 81)
    var Ao:[Int] = []
    var click = 0
    var select:IndexPath?
    var checked:[IndexPath] = []
    var undo:[Int:[Int]] = [:]
    var history:[Int] = []
    var f = true
    var marked:[IndexPath] = []
    var udf = false
    
    @IBOutlet weak var clv: UICollectionView!
    @IBOutlet weak var clv2: UICollectionView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let w = (clv.frame.size.width-16)/9
        let layout = clv.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: w, height: w)
        let w1 = (clv2.frame.size.width-4)/3
        let layout1 = clv2.collectionViewLayout as! UICollectionViewFlowLayout
        layout1.itemSize = CGSize(width: w1, height: w1)
        
        if UserDefaults.standard.object(forKey: "d") != nil, udf{
            let en = UserDefaults.standard.object(forKey: "d") as! Data
            let de = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(en) as! [Any]
            (A,B,Ao,click,checked,undo,marked,history) = (de[0],de[1],de[2],de[3],de[4],de[5],de[6],de[7]) as! ([Int], [Int], [Int], Int, [IndexPath], [Int : [Int]], [IndexPath], [Int])
        }else{
            (A,B) = (randboard(level))
            Ao = A
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let d = [A, B, Ao, click, checked, undo, marked, history] as [Any]
        let encoded = try! NSKeyedArchiver.archivedData(withRootObject: d, requiringSecureCoding: false)
        UserDefaults.standard.set(encoded, forKey: "d")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clv{
            return 81
            
        }else{return 9}
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clv{
            if f
            {
                f = false
                var s = [indexPath]
                if let ss = select, ss != indexPath {s.append(ss)}
                select = indexPath
                clv.reloadItems(at: s)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clv{
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath) as! c1cell
            let a = A[indexPath.item]
            let a0 = Ao[indexPath.item]
            cell1.layer.cornerRadius = 5
            
            if a != 0{
                cell1.ctxt.text = String(A[indexPath.item])
            }else{
                cell1.ctxt.text = ""
            }
            
            
            if checked.contains(indexPath){
                cell1.contentView.backgroundColor = UIColor(red: 155/256, green: 0/256, blue: 0/256, alpha: 0.33)
            }else if indexPath == select{
                cell1.contentView.backgroundColor = UIColor(red: 0/256, green: 0/256, blue: 155/256, alpha: 0.33)
            }else{
                cell1.contentView.backgroundColor = UIColor(red: 155/256, green: 166/256, blue: 0/256, alpha: 0.99)
            }
            
            if a0 != 0{
                cell1.ctxt.textColor = UIColor(red: 0/256, green: 0/256, blue: 0/256, alpha: 0.99)
            }else{
                cell1.ctxt.textColor = UIColor(red: 111/256, green: 0/256, blue: 222/256, alpha: 0.79)
            }
            
            if marked.contains(indexPath){
                cell1.contentView.backgroundColor = UIColor(red: 0/256, green: 99/256, blue: 255/256, alpha: 0.66)
            }
            
            f = true
            return cell1
            
        }else{
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
            cell2.layer.cornerRadius = 5
            return cell2
        }
    }
    
    func bindArray(_ bs:Binding) -> [Int] {
        let a = bs as! String
        var ba = a.components(separatedBy: ",") as [Any]
        var x = 0
        for i in ba{
            ba[x] = (i as! NSString).integerValue
            x+=1
        }
        return ba as! [Int]
    }
    
    func randboard(_ level:String)->([Int],[Int]){
        print(level)
        let path: String = Bundle.main.path(forResource: level, ofType: "db")!
        let db = try! Connection(path)
        let r = Int(truncatingIfNeeded: (try! db.scalar("select count(*) from mytable"))! as! Int64)
        let a = Int.random(in: 1...r)
        let board = bindArray(try! db.scalar("select board from mytable where id = ?", [a])!)
        let solved = bindArray(try! db.scalar("select solved from mytable where id = ?", [a])!)
        return (board, solved)
    }
    
    @IBAction func btn(_ sender: UIButton) {
        checked = []
        let a = sender.titleLabel!.text!
        if a == "Clear"{
            click=0
        }else{
            click = Int(a)!
        }
        if let i = select?.item, Ao[i] == 0{
            A[i] = click
            if undo[i] == nil{
                undo[i] = [0]
            }
            if undo[i]!.last != click{
                undo[i]!.append(click)
                history.append(i)
            }
        }
        if let s = select{clv.reloadItems(at: [s])}
        
        if a != "clear", A == B{
            let ac = UIAlertController(title: "Congratulations..", message: "You have finished the Puzzel", preferredStyle: .alert)
            present(ac, animated: true, completion:{
                ac.view.superview?.isUserInteractionEnabled = true
                ac.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))})
            ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
        print(undo)
    }
    
    @objc func dismissOnTapOutside(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func solve(_ sender: UIButton) {
        A = B
        checked = []
        clv.reloadData()
    }
    
    @IBAction func checkk(_ sender: UIButton) {
        checked = []
        for i in (0...80){
            if A[i] != B[i], A[i] != 0 {
                checked.append(IndexPath(item: i, section: 0))
            }
        }
        if !checked.isEmpty {clv.reloadItems(at: checked)}
    }
    
    @IBAction func undoo(_ sender: UIButton) {
        guard let s=select, let h = history.last else {return}
        
        if s.item != h{
            var ii = [s]
            select = IndexPath(item: h, section: 0)
            ii.append(select!)
            clv.reloadItems(at: ii)
            return}
        
        if undo[h]!.count>1{
            history.removeLast()
            undo[h]!.removeLast()
            A[h] = undo[h]!.last!
            clv.reloadItems(at: [IndexPath(item: h, section: 0)])
        }
        print(undo)
    }

    @IBAction func mark(_ sender: Any) {
        guard let s = select else {return}
        if marked.contains(s){
            marked = marked.filter{$0 != s}
        }else{
            marked.append(s)
        }
        clv.reloadItems(at: [s])
    }

}

