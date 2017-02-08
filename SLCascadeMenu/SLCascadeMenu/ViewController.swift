//
//  ViewController.swift
//  SLCascadeMenu
//
//  Created by Star88 on 17/2/8.
//  Copyright © 2017年 Star88. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onShowAction(_ sender: Any) {
        
        var list1 = [SLCascadeMenuItem]()
        
        var i = 0, j = 0, k = 0
        for _ in 0 ..< 2 {
            var item1 = SLCascadeMenuItem(menuId: "", title: "第一级\(i)")
            for _ in 0 ..< 10 {
                var item2 = SLCascadeMenuItem(menuId: "", title: "第二级\(j)")
                for _ in 0 ..< 5 {
                    item2.children.append(SLCascadeMenuItem(menuId: "", title: "第三级\(k)"))
                    k += 1
                }
                
                item1.children.append(item2)
                j += 1
            }
            list1.append(item1)
            i += 1
        }
        var item3 = SLCascadeMenuItem(menuId: "", title: "居室")
        item3.children.append(SLCascadeMenuItem(menuId: "2", title: "住宅"))
        item3.children.append(SLCascadeMenuItem(menuId: "3", title: "别墅"))
        item3.children.append(SLCascadeMenuItem(menuId: "4", title: "自住型商品房"))
        item3.children.append(SLCascadeMenuItem(menuId: "5", title: "两限房"))
        item3.children.append(SLCascadeMenuItem(menuId: "6", title: "写字楼"))
        item3.children.append(SLCascadeMenuItem(menuId: "7", title: "商铺"))
        
        i = 0
        j = 0
        var list2 = [SLCascadeMenuItem]()
        for _ in 0 ..< 2 {
            var item1 = SLCascadeMenuItem(menuId: "", title: "第一级\(i)")
            for _ in 0 ..< 5 {
                let item2 = SLCascadeMenuItem(menuId: "", title: "第二级\(j)")
                
                item1.children.append(item2)
                j += 1
            }
            list2.append(item1)
            i += 1
        }
        
        var rect = self.view.bounds
        rect.origin.y += 20
        rect.size.height -= 20
//        let view = SLCascadeMenuView.init(frame: rect, type: .collection, items: [item3], firstSelected: 0, secondSelected: 1)
        let view = SLCascadeMenuView.init(frame: rect, type: .normal, items: list1, firstSelected: 1)
//        let view = SLCascadeMenuView.init(frame: rect, type: .price, items: list2, firstSelected: 1)
        view.show(inView: self.view)
    }

}

