import 'package:flutter/material.dart';
import 'package:flutter_1st_test/utils/math.dart';
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
  final TextEditingController sampleMeanChance2Controller = TextEditingController();

  String selectedOption = "Menor P(T ≤ t)";
  double? mean;
  double? stdDeviation;
  double? resultadoT;
  double? resultadoT1;
  double? resultadoT2;
  double? resultadoProbabilidad;

  @override
  void initState() {
    super.initState();
    _addField();
  }

  void _addField() {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    focusNode.addListener(() {
      final index = focusNodes.indexOf(focusNode);
      final isLast = index == focusNodes.length - 1;

      if (focusNode.hasFocus && isLast) {
        _addField();
      }

      if (!focusNode.hasFocus &&
          controllers[index].text.trim().isEmpty &&
          controllers.length > 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _removeField(index);
          }
        });
      }
    });

    setState(() {
      controllers.add(controller);
      focusNodes.add(focusNode);
    });
  }

  void _removeField(int index) {
    setState(() {
      controllers[index].dispose();
      focusNodes[index].dispose();
      controllers.removeAt(index);
      focusNodes.removeAt(index);
    });
    calculateStatistics();
  }

  void calculateStatistics() {
    List<double> values = controllers
        .map((controller) => double.tryParse(controller.text))
        .where((value) => value != null)
        .map((value) => value!)
        .toList();

    final double? mu = double.tryParse(populationMeanController.text);
    final double? xBar1 = double.tryParse(sampleMeanChanceController.text);
    final double? xBar2 = double.tryParse(sampleMeanChance2Controller.text);

    if (values.length >= 2 && mu != null) {
      double sum = values.reduce((a, b) => a + b);
      int n = values.length;
      double localMean = sum / n;
      double degreesOfFreedom = n - 1;

      double squaredSum = values.fold(0.0, (acc, x) => acc + pow(x - localMean, 2));
      double localStdDev = sqrt(squaredSum / degreesOfFreedom);

      setState(() {
        mean = localMean;
        stdDeviation = localStdDev;
      });

      if (selectedOption == "Menor P(T ≤ t)") {
        if (xBar1 == null) {
          setState(() {
            resultadoT = resultadoProbabilidad = null;
            resultadoT1 = resultadoT2 = null;
          });
          return;
        }
        final double t = (xBar1 - mu) / (localStdDev / sqrt(n));
        setState(() {
          resultadoT = t;
          resultadoProbabilidad = studentsTArea(t, degreesOfFreedom);
          resultadoT1 = resultadoT2 = null;
        });
      }
      else if (selectedOption == "Mayor P(t ≤ T)") {
        if (xBar1 == null) {
          setState(() {
            resultadoT = resultadoProbabilidad = null;
            resultadoT1 = resultadoT2 = null;
          });
          return;
        }
        final double t = (xBar1 - mu) / (localStdDev / sqrt(n));
        setState(() {
          resultadoT = t;
          resultadoProbabilidad = 1 - studentsTArea(t, degreesOfFreedom);
          resultadoT1 = resultadoT2 = null;
        });
      }
      else if (selectedOption == "En medio (t_1 ≤ T ≤ t_2)") {
        if (xBar1 == null || xBar2 == null) {
          setState(() {
            resultadoT1 = resultadoT2 = resultadoProbabilidad = null;
            resultadoT = null;
          });
          return;
        }
        final double t1 = (xBar1 - mu) / (localStdDev / sqrt(n));
        final double t2 = (xBar2 - mu) / (localStdDev / sqrt(n));
        final double lower = min(t1, t2);
        final double upper = max(t1, t2);
        setState(() {
          resultadoT1 = t1;
          resultadoT2 = t2;
          resultadoProbabilidad = studentsTArea(upper, degreesOfFreedom) - 
                                studentsTArea(lower, degreesOfFreedom);
          resultadoT = null;
        });
      }
    } else {
      setState(() {
        mean = null;
        stdDeviation = null;
        resultadoT = resultadoT1 = resultadoT2 = resultadoProbabilidad = null;
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
                      textInputAction: index < controllers.length - 1 
                          ? TextInputAction.next 
                          : TextInputAction.done,
                      decoration: InputDecoration(labelText: 'Dato ${index + 1}'),
                      onChanged: (_) => calculateStatistics(),
                      onSubmitted: (_) {
                        if (index < focusNodes.length - 1) {
                          FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                        } else {
                          // If it's the last field, unfocus
                          focusNodes[index].unfocus();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
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
                    mean != null
                        ? 'Media muestral: ${mean!.toStringAsFixed(5)}'
                        : 'Media: ---',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stdDeviation != null
                        ? 'Desviación estándar muestral: ${stdDeviation!.toStringAsFixed(5)}'
                        : 'Desviación estándar muestral: ---',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: populationMeanController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Media poblacional (μ)'),
                    onChanged: (_) => calculateStatistics(),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 300, // Or use MediaQuery to make it responsive
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedOption,
                      items: const [
                        DropdownMenuItem(
                          value: "Menor P(T ≤ t)",
                          child: Text("Menor P(T ≤ t)"),
                        ),
                        DropdownMenuItem(
                          value: "Mayor P(t ≤ T)",
                          child: Text("Mayor P(t ≤ T)"),
                        ),
                        DropdownMenuItem(
                          value: "En medio (t_1 ≤ T ≤ t_2)",
                          child: Text("En medio (t_1 ≤ T ≤ t_2)"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                          sampleMeanChance2Controller.clear();
                          resultadoT = resultadoT1 = resultadoT2 = resultadoProbabilidad = null;
                        });
                        calculateStatistics();
                      },
                    ),
                  ),
                  TextField(
                    controller: sampleMeanChanceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: selectedOption == "En medio (t_1 ≤ T ≤ t_2)"
                          ? 'Media muestral 1 (x̄₁)'
                          : 'Media muestral (x̄)',
                    ),
                    onChanged: (_) => calculateStatistics(),
                  ),
                  if (selectedOption == "En medio (t_1 ≤ T ≤ t_2)")
                    TextField(
                      controller: sampleMeanChance2Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Media muestral 2 (x̄₂)'),
                      onChanged: (_) => calculateStatistics(),
                    ),
                  const SizedBox(height: 16),
                  if (selectedOption == "En medio (t_1 ≤ T ≤ t_2)" && resultadoT1 != null && resultadoT2 != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          't₁ = ${resultadoT1!.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          't₂ = ${resultadoT2!.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    )
                  else if (selectedOption != "En medio (t_1 ≤ T ≤ t_2)" && resultadoT != null)
                    Text(
                      't = ${resultadoT!.toStringAsFixed(5)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  const SizedBox(height: 8),
                  if (resultadoProbabilidad != null)
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                        children: [
                          TextSpan(
                            text: selectedOption == "Menor P(T ≤ t)"
                                ? 'P(T ≤ t) = '
                                : selectedOption == "Mayor P(t ≤ T)"
                                    ? 'P(t ≤ T) = '
                                    : 'P(t₁ ≤ T ≤ t₂) = ',
                          ),
                          TextSpan(
                            text: '${(resultadoProbabilidad! * 100).toStringAsFixed(5)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  if (resultadoT == null && resultadoT1 == null && resultadoProbabilidad == null)
                    const Text(
                      'Ingresa todos los valores correctamente.',
                      style: TextStyle(fontSize: 18),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}