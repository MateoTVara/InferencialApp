import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_1st_test/utils/math.dart';

class SDDMWithUnknownVariance extends StatefulWidget {
  const SDDMWithUnknownVariance({super.key});

  @override
  State<SDDMWithUnknownVariance> createState() => _SDDMWithUnknownVarianceState();
}

class _SDDMWithUnknownVarianceState extends State<SDDMWithUnknownVariance> {
  final TextEditingController mu1Controller = TextEditingController();
  final TextEditingController mu2Controller = TextEditingController();
  final TextEditingController s1SquaredController = TextEditingController();
  final TextEditingController s2SquaredController = TextEditingController();
  final TextEditingController n1Controller = TextEditingController();
  final TextEditingController n2Controller = TextEditingController();
  final TextEditingController sampleDiffController = TextEditingController();
  final TextEditingController sampleDiff1Controller = TextEditingController();
  final TextEditingController sampleDiff2Controller = TextEditingController();

  String selectedOption = "Menor P(T ≤ t)";
  double? resultadoT;
  double? resultadoT1;
  double? resultadoT2;
  double? resultadoProbabilidad;
  double? degreesOfFreedom;

  void calcularT() {
    final double? mu1 = double.tryParse(mu1Controller.text);
    final double? mu2 = double.tryParse(mu2Controller.text);
    final double? s1Squared = double.tryParse(s1SquaredController.text);
    final double? s2Squared = double.tryParse(s2SquaredController.text);
    final int? n1 = int.tryParse(n1Controller.text);
    final int? n2 = int.tryParse(n2Controller.text);

    if (mu1 == null || mu2 == null || s1Squared == null || s2Squared == null || 
        n1 == null || n2 == null || n1 <= 1 || n2 <= 1) {
      setState(() {
        resultadoT = resultadoT1 = resultadoT2 = resultadoProbabilidad = degreesOfFreedom = null;
      });
      return;
    }

    final double muDiff = mu1 - mu2;
    final double se = sqrt(s1Squared/n1 + s2Squared/n2);

    if (se == 0) {
      setState(() {
        resultadoT = resultadoT1 = resultadoT2 = resultadoProbabilidad = degreesOfFreedom = null;
      });
      return;
    }

    // Calculate degrees of freedom using Welch-Satterthwaite equation
    final double numerator = pow(s1Squared/n1 + s2Squared/n2, 2).toDouble();
    final double denominator = pow(s1Squared/n1, 2)/(n1 -1) + pow(s2Squared/n2, 2)/(n2 -1);
    final double df = numerator / denominator;

    if (selectedOption == "Menor P(T ≤ t)") {
      final double? xDiff = double.tryParse(sampleDiffController.text);
      if (xDiff == null) {
        setState(() {
          resultadoT = resultadoProbabilidad = degreesOfFreedom = null;
        });
        return;
      }
      final double t = (xDiff - muDiff) / se;
      final double prob = studentsTArea(t, df);
      setState(() {
        resultadoT = t;
        resultadoProbabilidad = prob;
        resultadoT1 = resultadoT2 = null;
        degreesOfFreedom = df;
      });
    }
    else if (selectedOption == "Mayor P(t ≤ T)") {
      final double? xDiff = double.tryParse(sampleDiffController.text);
      if (xDiff == null) return;
      final double t = (xDiff - muDiff) / se;
      final double prob = 1 - studentsTArea(t, df);
      setState(() {
        resultadoT = t;
        resultadoProbabilidad = prob;
        resultadoT1 = resultadoT2 = null;
        degreesOfFreedom = df;
      });
    }
    else if (selectedOption == "En medio (t_1 ≤ T ≤ t_2)") {
      final double? xDiff1 = double.tryParse(sampleDiff1Controller.text);
      final double? xDiff2 = double.tryParse(sampleDiff2Controller.text);
      if (xDiff1 == null || xDiff2 == null) return;
      
      final double t1 = (xDiff1 - muDiff) / se;
      final double t2 = (xDiff2 - muDiff) / se;
      final double lower = min(t1, t2);
      final double upper = max(t1, t2);
      
      final double prob = studentsTArea(upper, df) - studentsTArea(lower, df);
      setState(() {
        resultadoT1 = t1;
        resultadoT2 = t2;
        resultadoProbabilidad = prob;
        resultadoT = null;
        degreesOfFreedom = df;
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
              controller: mu1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Media poblacional 1 (μ₁)'),
              onChanged: (_) => calcularT(),
            ),
            TextField(
              controller: mu2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Media poblacional 2 (μ₂)'),
              onChanged: (_) => calcularT(),
            ),
            TextField(
              controller: s1SquaredController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Varianza muestral 1 (s₁²)'),
              onChanged: (_) => calcularT(),
            ),
            TextField(
              controller: s2SquaredController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Varianza muestral 2 (s₂²)'),
              onChanged: (_) => calcularT(),
            ),
            TextField(
              controller: n1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tamaño muestra 1 (n₁)'),
              onChanged: (_) => calcularT(),
            ),
            TextField(
              controller: n2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tamaño muestra 2 (n₂)'),
              onChanged: (_) => calcularT(),
            ),

            DropdownButton<String>(
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
                  resultadoT = resultadoT1 = resultadoT2 = resultadoProbabilidad = degreesOfFreedom = null;
                });
                calcularT();
              },
            ),

            if (selectedOption != "En medio (t_1 ≤ T ≤ t_2)")
              TextField(
                controller: sampleDiffController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Diferencia muestral (x̄₁ - x̄₂)'
                ),
                onChanged: (_) => calcularT(),
              )
            else
              Column(
                children: [
                  TextField(
                    controller: sampleDiff1Controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Diferencia muestral 1 (x̄₁ - x̄₂)₁'
                    ),
                    onChanged: (_) => calcularT(),
                  ),
                  TextField(
                    controller: sampleDiff2Controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Diferencia muestral 2 (x̄₁ - x̄₂)₂'
                    ),
                    onChanged: (_) => calcularT(),
                  ),
                ],
              ),

            const SizedBox(height: 20),
            if (degreesOfFreedom != null)
              Text(
                'Grados de libertad: ${degreesOfFreedom!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            if (selectedOption == "En medio (t_1 ≤ T ≤ t_2)" && resultadoT1 != null && resultadoT2 != null)
              Text(
                't₁ = ${resultadoT1!.toStringAsFixed(4)}, t₂ = ${resultadoT2!.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 18),
              )
            else if (selectedOption != "En medio (t_1 ≤ T ≤ t_2)" && resultadoT != null)
              Text(
                't = ${resultadoT!.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 18),
              ),
            
            if (resultadoProbabilidad != null)
              Text(
                selectedOption == "Menor P(T ≤ t)"
                    ? 'P(T ≤ t) = ${(resultadoProbabilidad! * 100).toStringAsFixed(2)}%'
                    : selectedOption == "Mayor P(t ≤ T)"
                        ? 'P(t ≤ T) = ${(resultadoProbabilidad! * 100).toStringAsFixed(2)}%'
                        : 'P(t₁ ≤ T ≤ t₂) = ${(resultadoProbabilidad! * 100).toStringAsFixed(2)}%',
                style: const TextStyle(fontSize: 18),
              ),
            
            if (resultadoT == null && resultadoT1 == null && resultadoProbabilidad == null)
              const Text(
                'Ingresa todos los valores correctamente',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}