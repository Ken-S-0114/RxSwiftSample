//
//  ViewController.swift
//  RxSwiftSample
//
//  Created by 佐藤賢 on 2018/01/21.
//  Copyright © 2018年 佐藤賢. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()

class ViewController: UIViewController {

  @IBOutlet weak var label1: UILabel!
  
  @IBOutlet weak var textField1: UITextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    textField1.rx.text.map{$0}.bind(to: label1.rx.text).disposed(by: disposeBag)
 
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
}

