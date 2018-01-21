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
  
  @IBOutlet weak var greetingLabel: UILabel!
  @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
  @IBOutlet weak var freeTextField: UITextField!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet var greetingButtons: [UIButton]!
  
  //観測対象のオブジェクトの一括解放用
  let disposeBag = DisposeBag()
  //初期化時の初期値の設定
  let lastSelectedGreeting: Variable<String> = Variable("こんにちは")
  //SegmentedControlに対応する値の定義
  enum State: Int {
    case useButtons
    case useTextField
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //「お名前:」の入力フィールドにおいて、テキスト入力のイベントを観測対象にする
    let nameObservable: Observable<String?> = nameTextField.rx.text.asObservable()
    //「自由入力:」の入力フィールドにおいて、テキスト入力のイベントを観測対象にする
    let freeObservable: Observable<String?> = freeTextField.rx.text.asObservable()
    //(combineLatest)「お名前:」と「自由入力:」それぞれの直近の最新値同士を結合する
    let freewordWithNameObservable: Observable<String?> = Observable.combineLatest(
    nameObservable,
    freeObservable
    ) { (string1: String?, string2: String?) in
      return string1! + string2!
    }
    //(bindTo)イベントのプロパティ接続をする ※bindToの引数内に表示対象のUIパーツを設定
    //(DisposeBag)購読[監視?]状態からの解放を行う
    freewordWithNameObservable.bind(to: greetingLabel.rx.text).disposed(by: disposeBag)
    
    //セグメントコントロールにおいて、値変化のイベントを観測対象にする
    let segmentedControlObservable: Observable<Int> = stateSegmentedControl.rx.value.asObservable()
    //セグメントコントロールの値変化を検知して、その状態に対応するenumの値を返す
    //(map)別の要素に変換する ※IntからStateへ変換
    let stateObservable: Observable<State> = segmentedControlObservable.map {
      (selectedIndex: Int) -> State in
      return State(rawValue: selectedIndex)!
    }
    //enumの値変化を検知して、テキストフィールドが編集を受け付ける状態かを返す
    //(map)別の要素に変換する ※StateからBoolへ変換
    let greetingTextFieldEnabledObservable: Observable<Bool> = stateObservable.map {
      (state: State) -> Bool in
      return state == .useTextField
    }
    //(bindTo)イベントのプロパティ接続をする ※bindToの引数内に表示対象のUIパーツを設定
    //(DisposeBag)観測状態からの解放を行う
    greetingTextFieldEnabledObservable.bind(to: freeTextField.rx.isEnabled).disposed(by: disposeBag)
    //テキストフィールドが編集を受け付ける状態かを検知して、ボタン部分が選択可能かを返す
    //(map)別の要素に変換する ※BoolからBoolへ変換
    let buttonsEnabledObservable: Observable<Bool> = greetingTextFieldEnabledObservable.map{
      (greetingEnabled: Bool) -> Bool in
      return !greetingEnabled
    }
    
    //アウトレットコレクションで接続したボタンに関する処理
    greetingButtons.forEach { button in
      //(bindTo)イベントのプロパティ接続をする ※bindToの引数内に表示対象のUIパーツを設定
      //(DisposeBag)観測状態からの解放を行う
      buttonsEnabledObservable.bind(to: button.rx.isEnabled).disposed(by: disposeBag)
      
      //メンバ変数：lastSelectedGreetingにボタンのタイトル名を引き渡す
      //(subscribe)イベントが発生した場合にイベントのステータスに応じての処理を行う
      button.rx.tap.subscribe(onNext: { (nothing: Void) in
        self.lastSelectedGreeting.value = button.currentTitle!
      }).disposed(by: disposeBag)
    }
    
    //挨拶の表示ラベルにおいて、テキスト表示のイベントを監視対象にする
    let predefinedGreetingObservable: Observable<String> = lastSelectedGreeting.asObservable()
    
    //最終的な挨拶文章のイベント
    //(combineLatest)現在入力ないしは選択がされている項目を全て結合する
    let finalGreetingObservable: Observable<String> = Observable.combineLatest(
      stateObservable,
      freeObservable,
      predefinedGreetingObservable,
      nameObservable) { (state: State, freeword: String?, predefinedGreeting: String, name: String?) -> String in
        switch state {
        case .useTextField:
          return freeword! + name!
        case .useButtons:
          return predefinedGreeting + name!
        }
    }
    
    //最終的な挨拶文章のイベント
    //(bindTo)イベントのプロパティ接続をする ※最終的な挨拶文章を表示する
    //(DisposeBag)購読[監視?]状態からの解放を行う
    finalGreetingObservable.bind(to: greetingLabel.rx.text).disposed(by: disposeBag)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
}

