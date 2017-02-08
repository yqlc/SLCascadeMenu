//
//  SLCascadeMenuItem.swift
//  TestCascadeMenu
//
//  Created by Start88 on 17/2/7.
//  Copyright © 2017年 Star88. All rights reserved.
//

import UIKit

struct SLCascadeMenuItem {
    var menuId: String
    var menuTitle: String
    var children = [SLCascadeMenuItem]()
    
    init(menuId: String, title: String) {
        self.menuId = menuId
        self.menuTitle = title
    }
}
