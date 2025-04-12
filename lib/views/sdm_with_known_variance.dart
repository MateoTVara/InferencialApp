import 'package:flutter/material.dart';
import 'package:flutter_1st_test/utils/math.dart';
import 'dart:math';

class SDMWithKnownVariance extends StatefulWidget {
  const SDMWithKnownVariance({super.key});

  @override
  State<SDMWithKnownVariance> createState() => _SDMWithKnownVarianceState();
}

class _SDMWithKnownVarianceState extends State<SDMWithKnownVariance> {
  final TextEditingController mediaPoblacionalController = TextEditingController();
  final TextEditingController desviacionEstandarController = TextEditingController();
  final TextEditingController muestraController = TextEditingController();
  final TextEditingController mediaMuestralController = TextEditingController();

  double? resultadoCDF;
  double? resultadoZ;

  void calcularZ() {
    final double? mu = double.tryParse(mediaPoblacionalController.text);
    final double? sigma = double.tryParse(desviacionEstandarController.text);
    final int? n = int.tryParse(muestraController.text);
    final double? xBar = double.tryParse(mediaMuestralController.text);

    if (mu != null && sigma != null && n != null && xBar != null && n > 0) {
      final double z = (xBar - mu) / (sigma / sqrt(n.toDouble()));
      setState(() {
        resultadoZ = z;
        resultadoCDF = normalCDF(z);
      });
    } else {
      setState(() {
        resultadoZ = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: mediaPoblacionalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Media poblacional (μ)'),
              onChanged: (_) => calcularZ(),
            ),
            TextField(
              controller: desviacionEstandarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Desviación estándar poblacional (σ)'),
              onChanged: (_) => calcularZ(),
            ),
            TextField(
              controller: muestraController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tamaño de muestra (n)'),
              onChanged: (_) => calcularZ(),
            ),
            TextField(
              controller: mediaMuestralController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Media muestral a evaluar (x̄)'),
              onChanged: (_) => calcularZ(),
            ),
            const SizedBox(height: 20),
            Text(
              resultadoZ != null
                  ? 'Z = ${resultadoZ!.toStringAsFixed(4)}'
                  : 'Ingresa todos los valores correctamente.',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              resultadoCDF != null
                  ? 'P(Z ≤ z) = ${(resultadoCDF! * 100).toStringAsFixed(2)}%'
                  : '',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

