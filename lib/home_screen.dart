import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as image_lib1;


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  loadTFlitedata() async {
    static const predictionModelPath =
      'assets/models/magenta_arbitrary-image-stylization-v1-256_int8_prediction_1.tflite';

    final interpreter = await Interpreter.fromAsset('assets/model.tflite');
    final isolateInterpreter =
        await IsolateInterpreter.create(address: interpreter.address);
        Image imageInput =
         Image.asset('assets/boy.jpg');

      // rotate image if android because camera image is landscape
      if (Platform.isAndroid) {
        imageInput = image_lib1.copyRotate(imageInput!, angle: 90);
      }

      // resize original image to match model shape.
      imageInput = image_lib.copyResize(
        imageInput!,
        width: isolateModel.inputShape[1],
        height: isolateModel.inputShape[2],
      );

      final imageMatrix = List.generate(
        int.parse("${imageInput.height!.toStringAsFixed(0)}"),
        (y) => List.generate(
          int.parse("${imageInput.width!.toStringAsFixed(0)}"),
          (x) {
            final pixel = imageInput!.getPixel(x, y);
            // normalize -1 to 1
            return [
              (pixel.r - 127.5) / 127.5,
              (pixel.b - 127.5) / 127.5,
              (pixel.g - 127.5) / 127.5
            ];
          },
        ),
      );

      // Set tensor input [1, 257, 257, 3]
      final input = [imageMatrix];
      // Set tensor output [1, 257, 257, 21]
      final output = [
        List.filled(
            isolateModel.outputShape[1],
            List.filled(isolateModel.outputShape[2],
                List.filled(isolateModel.outputShape[3], 0.0)))
      ];
      // // Run inference
      // Interpreter interpreter =
      //     Interpreter.fromAddress(isolateModel.interpreterAddress);
      interpreter.run(input, output);
      // Get first output tensor
      final result = output.first;

    // await isolateInterpreter.run(input, output);
    // await isolateInterpreter.runForMultipleInputs(inputs, outputs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Test"),
        ),
        body: Container(child: Text("Test")));
  }
}
