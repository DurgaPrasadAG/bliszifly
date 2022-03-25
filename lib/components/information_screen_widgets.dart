import 'dart:typed_data';

import 'package:bliszifly/themes/rounded_rectangle_border.dart';
import 'package:flutter/material.dart';

class BlisImageWidget extends StatelessWidget {
  const BlisImageWidget({
    Key? key, required this.bytes,
  }) : super(key: key);
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Card(
        shape: RoundRect.shape,
        elevation: 15,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.memory(bytes!, gaplessPlayback: true, fit: BoxFit.fill, cacheHeight: 500, cacheWidth: 500,), ),
      ),
    );
  }
}

class BlisAttributeWidget extends StatelessWidget {
   const BlisAttributeWidget({
    Key? key, required this.attributeName, required this.attributeValue,
  }) : super(key: key);

  final String attributeName;
  final String attributeValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 10,
        ),
        Card(
          elevation: 15.0,
          shape: RoundRect.shape,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Text(attributeName, style: const TextStyle(fontSize: 25),)),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(attributeValue, style: const TextStyle(fontSize: 18),),
              )
            ],
          ),
        ),
      ],
    );
  }
}