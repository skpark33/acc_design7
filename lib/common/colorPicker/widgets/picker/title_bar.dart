import 'package:flutter/material.dart';

//import '../../theme.dart';
import 'package:acc_design7/constants/strings.dart';

class MainTitle extends StatelessWidget {
  final VoidCallback? onClose;

  const MainTitle({Key? key, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              MyStrings.mainTitle,
              style: textTheme.subtitle2,
            ),
          ),
          onClose != null
              ? IconButton(icon: const Icon(Icons.close), onPressed: onClose)
              : const SizedBox(height: 48)
        ],
      ),
    );
  }
}
