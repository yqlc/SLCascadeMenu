//
//  SLCascadeMenuView.swift
//  TestCascadeMenu
//
//  Created by Star88 on 17/2/7.
//  Copyright © 2017年 Star88 . All rights reserved.
//

import UIKit

enum SLCascadeMenuType {
    case normal, price, collection
}

class SLCascadeMenuView: UIView {
    internal var _normalItemHeight: CGFloat = 40
    internal var _collectionItemHeight: CGFloat = 36
    internal var _priceInputHeight: CGFloat = 34
    internal var _normalItemColor = UIColor.black
    internal var _selectItemColor = UIColor.orange
    internal var _multiseriateFirstWidth: CGFloat = 100
    internal var _multiseriateFirstBgColor: UIColor = UIColor.gray
    
    // 选中了某个菜单项
    var handleSelectedItem: ((SLCascadeMenuItem) -> Void)?
    // 点击自定义输入的确定后的事件处理，返回 true 时会自动关闭级联菜单
    var handleCustomInput: ((String?, String?) -> Bool)?
    
    private var _type: SLCascadeMenuType = .normal
    private var _height: CGFloat = 0
    
    internal var _cascadeCount = 1
    internal lazy var _items = [SLCascadeMenuItem]()
    internal lazy var _secondItems = [SLCascadeMenuItem]()
    internal lazy var _thirdItems = [SLCascadeMenuItem]()
    
    internal lazy var _firstIndex = 0
    internal lazy var _secondIndex = 0
    internal lazy var _thirdIndex = 0
    
    internal lazy var _contentView: UIView = { [unowned self] in
        let view  = UIView()
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        return view
    }()
    
    internal lazy var _collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 15
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.white
        collection.dataSource = self
        collection.delegate = self
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "idtCollectionItem")
        collection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "idtCollectionHeader")
        return collection
    }()
    
    internal lazy var _firstTable: UITableView = { [unowned self] in
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.backgroundColor = UIColor.white
        table.dataSource = self
        table.delegate = self
        table.rowHeight = self._normalItemHeight
        table.separatorInset = UIEdgeInsets.zero
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "idtNormalItem")
        return table
    }()
    
    internal lazy var _secondTable: UITableView = { [unowned self] in
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.backgroundColor = UIColor.white
        table.dataSource = self
        table.delegate = self
        table.rowHeight = self._normalItemHeight
        table.separatorInset = UIEdgeInsets.zero
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "idtNormalItem")
        return table
    }()
    
    internal lazy var _thirdTable: UITableView = { [unowned self] in
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.backgroundColor = UIColor.white
        table.dataSource = self
        table.delegate = self
        table.rowHeight = self._normalItemHeight
        table.separatorInset = UIEdgeInsets.zero
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "idtNormalItem")
        return table
    }()
    
    internal lazy var _middleSep: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    internal lazy var _bottomInput: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()
    
    internal lazy var _minInput: UITextField = { [unowned self] in
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.keyboardType = .numberPad
        return field
    }()
    
    internal lazy var _maxInput: UITextField = { [unowned self] in
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.keyboardType = .numberPad
        return field
    }()
    
    /// 初始化一个级联菜单，最多支持三级
    ///
    /// - Parameters:
    ///   - frame: 显示区域
    ///   - type: 菜单类型
    ///   - items: 菜单数据
    ///   - firstSelected: 第一级默认选中的下标（当类型为collection时，表示组的序号）
    ///   - secondSelected: 第二级默认选中的下标（当类型为collection时，表示对应组下某个菜单的序号）
    ///   - thirdSelected: 第三级默认选中的下标
    convenience init(frame: CGRect, type: SLCascadeMenuType, items: [SLCascadeMenuItem], firstSelected: Int = 0, secondSelected: Int = 0, thirdSelected: Int = 0) {
        self.init(frame: frame)
        _type = type
        _items.append(contentsOf: items)
        
        _firstIndex = firstSelected
        _secondIndex = secondSelected
        _thirdIndex = thirdSelected
        
        // 最大高度
        let maxHeight = frame.height * 0.5
        
        // 点击空白遮罩消失
        let button = UIButton()
        button.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)])
        
        addSubview(_contentView)
        _contentView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        if _type != .collection {
            
            _contentView.addSubview(_firstTable)
            _firstTable.frame = _contentView.bounds
            
            _contentView.addSubview(_secondTable)
            _secondTable.frame = _contentView.bounds
            
            _contentView.addSubview(_thirdTable)
            _thirdTable.frame = _contentView.bounds
            
            let secondList = items.flatMap { item -> [SLCascadeMenuItem]? in
                if item.children.count > 0 {
                    return item.children
                }
                return nil
            }
            
            var maxCount = max(_items.count, secondList.max(by: { $0.count > $1.count })?.count ?? 0)
            
            let secondItems = secondList.joined()
            if !secondItems.isEmpty {
                _cascadeCount += 1
                
                if _firstIndex >= 0 && _firstIndex < _items.count {
                    _secondItems.append(contentsOf: _items[_firstIndex].children)
                }
                
                let thirdList = secondItems.flatMap { item -> [SLCascadeMenuItem]? in
                    if item.children.count > 0 {
                        return item.children
                    }
                    return nil
                }
                let thirdItems = thirdList.joined()
                
                // 最多支持三级
                if !thirdItems.isEmpty {
                    _cascadeCount += 1
                    
                    if _secondIndex >= 0 && _secondIndex < _secondItems.count {
                        _thirdItems.append(contentsOf: _secondItems[_secondIndex].children)
                    }
                    
                    maxCount = max(maxCount, thirdList.max(by: { $0.count > $1.count })?.count ?? 0)
                }
            }
            
            _firstTable.reloadData()
            _secondTable.reloadData()
            _thirdTable.reloadData()
            
            let offset: CGFloat = _type == .price ? _priceInputHeight : 0
            _height = min(CGFloat(maxCount) * _normalItemHeight + offset, maxHeight)
            
            let tableHeight = _height - offset
            if _cascadeCount == 1 {
                _firstTable.frame.size = CGSize(width: frame.width, height:tableHeight)
                _secondTable.isHidden = true
                _thirdTable.isHidden = true
            } else {
                _firstTable.frame.size = CGSize(width: _multiseriateFirstWidth, height: tableHeight)
                _firstTable.backgroundColor = _multiseriateFirstBgColor
                
                var width = frame.width - _firstTable.frame.width
                if _cascadeCount > 2 {
                    width = _cascadeCount > 2 ? (width - 0.5) * 0.5 : width
                    _secondTable.frame = CGRect(x: _firstTable.frame.maxX, y: 0, width: width, height: tableHeight)
                    
                    width = frame.width - _firstTable.frame.width - _secondTable.frame.width - 0.5
                    _thirdTable.frame = CGRect(x: _secondTable.frame.maxX + 0.5, y: 0, width: width, height: tableHeight)
                } else {
                    _secondTable.frame = CGRect(x: _firstTable.frame.width, y: 0, width: width, height: tableHeight)
                    _thirdTable.isHidden = true
                }
            }
            
            if _type == .price {
                _contentView.addSubview(_bottomInput)
                _bottomInput.frame = CGRect(x: 0, y: tableHeight, width: _contentView.frame.width, height: offset)
                
                setupBottomInput()
            }
        } else {
            _contentView.addSubview(_collectionView)
            _collectionView.frame = _contentView.bounds
            _collectionView.collectionViewLayout.prepare()
            _collectionView.reloadData()
            
            _height = min(_collectionView.collectionViewLayout.collectionViewContentSize.height, maxHeight)
            _collectionView.frame.size.height = _height
        }
    }
    
    func show(inView: UIView) {
        inView.addSubview(self)
        
        backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.15) {
            self.backgroundColor = UIColor(white: 0, alpha: 0.3)
        }
        
        _contentView.frame.size.height = 0
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: { 
            self._contentView.frame.size.height = self._height
        }, completion: nil)
    }
    
    func hide() {
        hideAnimated(nil)
    }
    
    // MARK:
    @objc private func handleCloseAction(sender: AnyObject?) {
        guard !_minInput.isFirstResponder && !_maxInput.isFirstResponder else {
            _minInput.resignFirstResponder()
            _maxInput.resignFirstResponder()
            return
        }
        hide()
    }
    
    internal func hideAnimated(_ callback: (() -> Void)?) {
        UIView.animate(withDuration: 0.2) {
            self._contentView.frame.size.height = 0
        }
        
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
            self.backgroundColor = UIColor.clear
        }) { [weak self] finished in
            self?.isUserInteractionEnabled = true
            self?.removeFromSuperview()
            callback?()
        }
    }

    private func setupBottomInput() {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "自定义"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: _multiseriateFirstWidth, height: _bottomInput.frame.height)
        _bottomInput.addSubview(label)
        
        let button = UIButton(type: .system)
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor.orange
        button.addTarget(self, action: #selector(handleInputSureAction), for: .touchUpInside)
        button.frame = CGRect(x: _bottomInput.frame.width - 20 - 60, y: (_bottomInput.frame.height - 26) * 0.5, width: 60, height: 26)
        _bottomInput.addSubview(button)
        
        let left = label.frame.maxX + 20
        var width = button.frame.minX - 20 - left
        let sepWidth: CGFloat = 8
        let sepView = UIView()
        sepView.backgroundColor = UIColor.orange
        sepView.frame = CGRect(x: left + (width - sepWidth) * 0.5, y: (_bottomInput.frame.height - 1) * 0.5, width: sepWidth, height: 1)
        _bottomInput.addSubview(sepView)
        
        width = (width - sepWidth) * 0.5 - 8
        _minInput.frame = CGRect(x: left, y: button.frame.minY, width: width, height: button.frame.height)
        _bottomInput.addSubview(_minInput)
        
        _maxInput.frame = CGRect(x: sepView.frame.maxX + 8, y: button.frame.minY, width: width, height: button.frame.height)
        _bottomInput.addSubview(_maxInput)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapAction))
        gesture.delegate = self
        gesture.cancelsTouchesInView = true
        addGestureRecognizer(gesture)
    }
    
    @objc private func handleInputSureAction(sender: AnyObject?) {
        if let call = handleCustomInput {
            if call(_minInput.text, _maxInput.text) {
                hide()
            }
        } else {
            hide()
        }
    }
    
    @objc private func handleTapAction(sender: AnyObject?) {
        _minInput.resignFirstResponder()
        _maxInput.resignFirstResponder()
    }
}

extension SLCascadeMenuView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _items[section].children.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "idtCollectionItem", for: indexPath)
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = _normalItemColor.cgColor
        cell.backgroundColor = UIColor.lightGray
        
        if (cell.contentView.viewWithTag(10) as? UILabel) == nil {
            let label = UILabel()
            label.textColor = _normalItemColor
            label.font = UIFont.systemFont(ofSize: 15)
            label.textAlignment = .center
            label.tag = 10
            cell.contentView.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addConstraints([
                NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: cell.contentView, attribute: .left, multiplier: 1, constant: 8),
                NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: cell.contentView, attribute: .right, multiplier: 1, constant: -8),
                NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: cell.contentView, attribute: .centerY, multiplier: 1, constant: 0)])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "idtCollectionHeader", for: indexPath)
        
        if (view.viewWithTag(11) as? UILabel) == nil {
            let label = UILabel()
            label.textColor = _normalItemColor
            label.font = UIFont.systemFont(ofSize: 15)
            label.textAlignment = .left
            label.tag = 11
            view.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints([
                NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 10),
                NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -10),
                NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)])
        }
        
        if view.viewWithTag(12) == nil {
            let sepView = UIView()
            sepView.backgroundColor = UIColor.gray
            sepView.tag = 12
            view.addSubview(sepView)
            
            sepView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints([
                NSLayoutConstraint(item: sepView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: sepView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: sepView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: sepView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0.5)])
        }
        
        return view
    }
}

extension SLCascadeMenuView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = _items[indexPath.section].children[indexPath.item]
        
        var size = CGSize(width: 16, height: _collectionItemHeight)
        size.width += ceil((item.menuTitle as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: size.height), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)], context: nil).width)

        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 34)
    }
}

extension SLCascadeMenuView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let label = cell.contentView.viewWithTag(10) as? UILabel
        label?.text = _items[indexPath.section].children[indexPath.item].menuTitle
        
        if indexPath.section == _firstIndex && indexPath.item == _secondIndex {
            cell.layer.borderColor = _selectItemColor.cgColor
            
            let label = cell.contentView.viewWithTag(10) as? UILabel
            label?.textColor = _selectItemColor
        } else {
            cell.layer.borderColor = _normalItemColor.cgColor
            
            let label = cell.contentView.viewWithTag(10) as? UILabel
            label?.textColor = _normalItemColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        let label = view.viewWithTag(11) as? UILabel
        label?.text = _items[indexPath.section].menuTitle
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _firstIndex = indexPath.section
        _secondIndex = indexPath.item
        
        collectionView.reloadData()
        
        let item = _items[_firstIndex].children[_secondIndex]
        hideAnimated { [weak self] in
            self?.handleSelectedItem?(item)
        }
    }
}

extension SLCascadeMenuView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == _firstTable {
            return _items.count
        } else if tableView == _secondTable {
            return _secondItems.count
        } else if tableView == _thirdTable {
            return _thirdItems.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idtNormalItem", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

extension SLCascadeMenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == _firstTable {
            cell.textLabel?.text = _items[indexPath.row].menuTitle
            cell.textLabel?.textColor = _firstIndex == indexPath.row ? _selectItemColor : _normalItemColor
        } else if tableView == _secondTable {
            cell.textLabel?.text = _secondItems[indexPath.row].menuTitle
            cell.textLabel?.textColor = _secondIndex == indexPath.row ? _selectItemColor : _normalItemColor
        } else if tableView == _thirdTable {
            cell.textLabel?.text = _thirdItems[indexPath.row].menuTitle
            cell.textLabel?.textColor = _thirdIndex == indexPath.row ? _selectItemColor : _normalItemColor
        } else {
            cell.textLabel?.text = ""
            cell.textLabel?.textColor = _normalItemColor
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == _firstTable {
            _firstIndex = indexPath.row
            let item = _items[_firstIndex]
            if _cascadeCount > 1 {
                tableView.reloadData()
                
                _secondItems.removeAll()
                _thirdItems.removeAll()
                
                _secondItems.append(contentsOf: item.children)
                _secondIndex = 0
                _secondTable.reloadData()
                _secondTable.setContentOffset(CGPoint.zero, animated: true)
                
                if !_secondItems.isEmpty {
                    if let second = _secondItems.first {
                        _thirdItems.append(contentsOf: second.children)
                    }
                }
                
                _thirdIndex = 0
                _thirdTable.reloadData()
                _thirdTable.setContentOffset(CGPoint.zero, animated: true)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
                hideAnimated { [weak self] in
                    self?.handleSelectedItem?(item)
                }
            }
        } else if tableView == _secondTable {
            _secondIndex = indexPath.row
            let item = _secondItems[_secondIndex]
            
            if _cascadeCount == 2 {
                tableView.deselectRow(at: indexPath, animated: true)
                hideAnimated { [weak self] in
                    self?.handleSelectedItem?(item)
                }
            } else {
                tableView.reloadData()
                
                _thirdItems.removeAll()
                _thirdItems.append(contentsOf: item.children)
                _thirdIndex = 0
                _thirdTable.reloadData()
                _thirdTable.setContentOffset(CGPoint.zero, animated: true)
            }
        } else if tableView == _thirdTable {
            _thirdIndex = indexPath.row
            let item = _thirdItems[_thirdIndex]
            
            tableView.deselectRow(at: indexPath, animated: true)
            hideAnimated { [weak self] in
                self?.handleSelectedItem?(item)
            }
        }
    }
}

extension SLCascadeMenuView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return _minInput.isFirstResponder || _maxInput.isFirstResponder
    }
}
