import 'package:provider/provider.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';

//import 'package:acc_design7/model/contents.dart';
import 'package:acc_design7/player/play_manager.dart';
import 'package:acc_design7/model/pages.dart';
import 'package:acc_design7/studio/properties/property_selector.dart';
import 'package:acc_design7/studio/properties/properties_frame.dart';
import 'package:acc_design7/constants/strings.dart';
import 'package:acc_design7/constants/styles.dart';
//import 'package:acc_design7/common/util/my_utils.dart';

// ignore: must_be_immutable
class ContentsProperty extends PropertySelector {
  ContentsProperty(
    Key? key,
    PageModel? pselectedPage,
    bool pisNarrow,
    bool pisLandscape,
    PropertiesFrameState parent,
  ) : super(
          key: key,
          selectedPage: pselectedPage,
          isNarrow: pisNarrow,
          isLandscape: pisLandscape,
          parent: parent,
        );
  @override
  State<ContentsProperty> createState() => ContentsPropertyState();
}

class ContentsPropertyState extends State<ContentsProperty> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        thickness: 8.0,
        scrollbarOrientation: ScrollbarOrientation.left,
        isAlwaysShown: true,
        controller: _scrollController,
        child: Consumer<SelectedModel>(builder: (context, selectedModel, child) {
          return ListView(controller: _scrollController, children: [
            _titleRow(25, 15, 12, 10),
            Text('Name : ${selectedModel.getModel()!.name}')
          ]);
        }));
  }

  Widget _titleRow(double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Text(
        MyStrings.contentsPropTitle,
        style: MyTextStyles.body1,
      ),
    );
  }
}
