import 'package:acc_design7/acc/acc_manager.dart';
import 'package:flutter/material.dart';

import '../../model/pages.dart';
import '../../common/undo/undo.dart';
import 'package:sortedmap/sortedmap.dart';

enum PropertyType {
  page,
  acc,
  contents,
}

PageManager? pageManagerHolder;

class PageManager extends ChangeNotifier {
  // factory PageManager.singleton() {
  //   return PageManager();
  // }
  PageManager() {
    load();
  }

  int pageIndex = 0;
  Map<int, PageModel> pageMap = <int, PageModel>{};
  SortedMap<int, PageModel> orderMap = SortedMap<int, PageModel>();

  PropertyType _propertyType = PropertyType.page;

  void setAsAcc() {
    _propertyType = PropertyType.acc;
    notifyListeners();
  }

  void setAsPage() {
    _propertyType = PropertyType.page;
    notifyListeners();
  }

  void setAsContents() {
    _propertyType = PropertyType.contents;
    notifyListeners();
  }

  bool isAcc() {
    return _propertyType == PropertyType.acc;
  }

  bool isPage() {
    return _propertyType == PropertyType.page;
  }

  bool isContents() {
    return _propertyType == PropertyType.contents;
  }

  int lastWidth = 1920;
  int lastHeight = 1080;

  int _selectedIndex = -1;

  void load() {
    if (loadBook() == 0) {
      createPage();
      _selectedIndex = 0;
    }
  }

  int loadBook() {
    return 0;
  }

  void createPage() {
    PageModel page = PageModel(id: pageIndex);
    page.setPageNo(pageIndex);
    pageMap[pageIndex] = page;
    orderMap[page.pageNo.value] = page;
    pageIndex++;
  }

  void removePage(int pageIndex) {
    pageMap[pageIndex]!.setIsRemoved(true);
  }

  changeOrder(int newIndex, int oldIndex) {
    mychangeStack.startTrans();
    orderMap[newIndex]!.setPageNo(oldIndex);
    orderMap[oldIndex]!.setPageNo(newIndex);
    mychangeStack.endTrans();
  }

  bool isSelected(int index) {
    return _selectedIndex == index;
  }

  PageModel? getSelected() {
    if (_selectedIndex < 0) {
      return null;
    }
    return pageMap[_selectedIndex];
  }

  void setSelectedIndex(BuildContext context, int val) {
    _selectedIndex = val;
    accManagerHolder!.showPages(context, val);
    setState();
  }

  void reorderMap() {
    orderMap.clear();
    for (PageModel model in pageMap.values) {
      if (model.isRemoved.value == false) {
        orderMap[model.pageNo.value] = model;
      }
    }
  }

  void setState() {
    notifyListeners();
  }
}
