import 'package:flutter/material.dart';

class NoItemWidget extends StatelessWidget {
  const NoItemWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      // color: Colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            'No hay elementos, Agrega uno',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Icon(
            Icons.mood_bad,
            size: 100,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
