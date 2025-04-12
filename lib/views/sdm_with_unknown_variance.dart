import 'package:flutter/material.dart';
import 'dart:math';

class SDMWithUnknownVariance extends StatefulWidget {
  const SDMWithUnknownVariance({super.key});

  @override
  State<SDMWithUnknownVariance> createState() => _SDMWithUnknownVarianceState();
}

class _SDMWithUnknownVarianceState extends State<SDMWithUnknownVariance> {
  List<TextEditingController> controllers = [];
  List<FocusNode> focusNodes = [];
  final TextEditingController populationMeanController = TextEditingController();
  final TextEditingController sampleMeanChanceController = TextEditingController();

  double? media;
  double? desviacion;
  double? z;
  double? resultTCDF;

  @override
  void initState() {
    super.initState();
    _addCampo();
  }

  void _addCampo() {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    focusNode.addListener(() {
      final index = focusNodes.indexOf(focusNode);
      final isLast = index == focusNodes.length - 1;

      if (focusNode.hasFocus && isLast) {
        _addCampo();
      }

      if (!focusNode.hasFocus &&
          controllers[index].text.trim().isEmpty &&
          controllers.length > 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _removeCampo(index);
          }
        });
      }
    });

    setState(() {
      controllers.add(controller);
      focusNodes.add(focusNode);
    });
  }

  void _removeCampo(int index) {
    setState(() {
      controllers[index].dispose();
      focusNodes[index].dispose();
      controllers.removeAt(index);
      focusNodes.removeAt(index);
    });
    calcularEstadisticas();
  }

  void calcularEstadisticas() {
    List<double> valores = controllers
        .map((controller) => double.tryParse(controller.text))
        .where((valor) => valor != null)
        .map((valor) => valor!)
        .toList();
    
    final double? mu = double.tryParse(populationMeanController.text);
    final double? xBar = double.tryParse(sampleMeanChanceController.text);

    if (valores.length >= 2 && mu != null && xBar != null) {
      double suma = valores.reduce((a, b) => a + b);
      int populationDegreesOfFreedom = valores.length;
      double mediaLocal = suma / populationDegreesOfFreedom;
      int degreesOfFreedom = populationDegreesOfFreedom - 1;

      double sumaCuadrados = valores.fold(0.0, (acum, x) => acum + pow(x - mediaLocal, 2));
      double desviacionLocal = sqrt(sumaCuadrados / (degreesOfFreedom));

      double zLocal = (xBar - mu) / (desviacionLocal / sqrt(valores.length));

      setState(() {
        media = mediaLocal;
        desviacion = desviacionLocal;
        z = zLocal;
        // resultTCDF = tCDF(zLocal, degreesOfFreedom);
      });
    } else {
      setState(() {
        media = null;
        desviacion = null;
        z = null;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // LADO IZQUIERDO: Inputs
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: controllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Dato ${index + 1}'),
                      onChanged: (_) => calcularEstadisticas(),
                    ),
                  );
                },
              ),
            ),
          ),

          // LADO DERECHO: Resultados
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resultados',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    media != null
                        ? 'Media muestral: ${media!.toStringAsFixed(5)}'
                        : 'Media: ---',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desviacion != null
                        ? 'Desviación estándar muestral (x̄): ${desviacion!.toStringAsFixed(5)}'
                        : 'Desviación estándar muestral (x̄): ---',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: populationMeanController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Media poblacional (μ)'),
                    onChanged: (_) => calcularEstadisticas(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: sampleMeanChanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Media muestral  a evaluar (x̄)'),
                    onChanged: (_) => calcularEstadisticas(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    z != null
                        ? 'Valor estandarizado (t): ${z!.toStringAsFixed(5)}'
                        : 'Valor estanzarizado (t): ---',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  /*Text(
                    resultTCDF != null
                        ? 'P(Z ≤ z) = ${(resultTCDF! * 100).toStringAsFixed(2)}%'
                        : 'P(Z ≤ z): ---',
                    style: const TextStyle(fontSize: 18),
                  ),*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
