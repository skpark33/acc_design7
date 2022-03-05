import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:sortedmap/sortedmap.dart';

import 'package:acc_design7/acc/acc_manager.dart';
import 'package:acc_design7/constants/strings.dart';
import '../../model/pages.dart';
import '../../common/undo/undo.dart';

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
  List<Node> nodes = [];

  PropertyType _propertyType = PropertyType.page;
  PropertyType get propertyType => _propertyType;
  void setPropertyType(PropertyType p) {
    _propertyType = p;
  }

  Future<void> setAsAcc() async {
    _propertyType = PropertyType.acc;
    notifyListeners();
  }

  Future<void> setAsPage() async {
    _propertyType = PropertyType.page;
    notifyListeners();
  }

  Future<void> setAsContents() async {
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

  List<Node> mapToNodes() {
    //  Node(
    //       label: 'documents',
    //       key: 'docs',
    //       expanded: docsOpen,
    //       // ignore: dead_code
    //       icon: docsOpen ? Icons.folder_open : Icons.folder,
    //       children: [ ]
    //  );
    for (PageModel model in orderMap.values) {
      if (model.isRemoved.value == false) {
        String pageNo = (model.pageNo.value + 1).toString().padLeft(2, '0');
        String desc = model.description.value;
        if (desc.isEmpty) {
          desc = MyStrings.title + ' $pageNo';
        }
        List<Node> accNodes = accManagerHolder!.getAccNodes(model);
        nodes.add(Node(
            key: model.id.toString(),
            label: 'Page $pageNo. $desc',
            data: model,
            children: accNodes));
      }
    }
    return nodes;
  }
}
