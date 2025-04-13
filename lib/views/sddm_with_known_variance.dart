import 'package:flutter/material.dart';
import 'package:flutter_1st_test/utils/math.dart';
import 'dart:math';

class SDDMWithKnownVariance extends StatefulWidget {
  const SDDMWithKnownVariance({super.key});

  @override
  State<SDDMWithKnownVariance> createState() => _SDDMWithKnownVarianceState();
}

class _SDDMWithKnownVarianceState extends State<SDDMWithKnownVariance> {
  final TextEditingController mu1Controller = TextEditingController();
  final TextEditingController mu2Controller = TextEditingController();
  final TextEditingController va1Controller = TextEditingController();
  final TextEditingController va2Controller = TextEditingController();
  final TextEditingController n1Controller = TextEditingController();
  final TextEditingController n2Controller = TextEditingController();
  final TextEditingController sampleDiffController = TextEditingController();
  final TextEditingController sampleDiff1Controller = TextEditingController();
  final TextEditingController sampleDiff2Controller = TextEditingController();

  String selectedOption = "Menor P(Z ≤ z)";
  double? resultadoZ;
  double? resultadoZ1;
  double? resultadoZ2;
  double? resultadoProbabilidad;

  void calcularZ() {
    final double? mu1 = double.tryParse(mu1Controller.text);
    final double? mu2 = double.tryParse(mu2Controller.text);
    final double? va1 = double.tryParse(va1Controller.text);
    final double? va2 = double.tryParse(va2Controller.text);
    final int? n1 = int.tryParse(n1Controller.text);
    final int? n2 = int.tryParse(n2Controller.text);

    if (mu1 == null || mu2 == null || va1 == null || va2 == null || 
        n1 == null || n2 == null || n1 <= 0 || n2 <= 0) {
      setState(() {
        resultadoZ = resultadoZ1 = resultadoZ2 = resultadoProbabilidad = null;
      });
      return;
    }

    final double muDiff = mu1 - mu2;
    final double se = sqrt(va1/n1 + va2/n2);

    if (selectedOption == "Menor P(Z ≤ z)") {
      final double? xDiff = double.tryParse(sampleDiffController.text);
      if (xDiff == null) {
        setState(() {
          resultadoZ = resultadoProbabilidad = null;
        });
        return;
      }
      final double z = (xDiff - muDiff) / se;
      setState(() {
        resultadoZ = z;
        resultadoProbabilidad = normalCDF(z);
        resultadoZ1 = resultadoZ2 = null;
      });
    }
    else if (selectedOption == "Mayor P(z ≤ Z)") {
      final double? xDiff = double.tryParse(sampleDiffController.text);
      if (xDiff == null) return;
      final double z = (xDiff - muDiff) / se;
      setState(() {
        resultadoZ = z;
        resultadoProbabilidad = 1 - normalCDF(z);
        resultadoZ1 = resultadoZ2 = null;
      });
    }
    else if (selectedOption == "En medio (z_1 ≤ Z ≤ z_2)") {
      final double? xDiff1 = double.tryParse(sampleDiff1Controller.text);
      final double? xDiff2 = double.tryParse(sampleDiff2Controller.text);
      if (xDiff1 == null || xDiff2 == null) return;
      
      final double z1 = (xDiff1 - muDiff) / se;
      final double z2 = (xDiff2 - muDiff) / se;
      final double lower = min(z1, z2);
      final double upper = max(z1, z2);
      
      setState(() {
        resultadoZ1 = z1;
        resultadoZ2 = z2;
        resultadoProbabilidad = normalCDF(upper) - normalCDF(lower);
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
            // Population parameters
            TextField(
              controller: mu1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Media poblacional 1 (μ₁)'),
              onChanged: (_) => calcularZ(),
            ),
            TextField(
              controller: mu2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Media poblacional 2 (μ₂)'),
              onChanged: (_) => calcularZ(),
            ),
            TextField(
              controller: va1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Varianza 1 (σ₁²)'),
              onChanged: (_) => calcularZ(),
            ),
            TextField(
              controller: va2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Varianza 2 (σ₂²)'),
              onChanged: (_) => calcularZ(),
            ),
            TextField(
              controller: n1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tamaño muestra 1 (n₁)'),
              onChanged: (_) => calcularZ(),
            ),
            TextField(
              controller: n2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tamaño muestra 2 (n₂)'),
              onChanged: (_) => calcularZ(),
            ),

            // Test type selector
            DropdownButton<String>(
              value: selectedOption,
              items: const [
                DropdownMenuItem(
                  value: "Menor P(Z ≤ z)",
                  child: Text("Menor P(Z ≤ z)"),
                ),
                DropdownMenuItem(
                  value: "Mayor P(z ≤ Z)",
                  child: Text("Mayor P(z ≤ Z)"),
                ),
                DropdownMenuItem(
                  value: "En medio (z_1 ≤ Z ≤ z_2)",
                  child: Text("En medio (z_1 ≤ Z ≤ z_2)"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                  resultadoZ = resultadoZ1 = resultadoZ2 = resultadoProbabilidad = null;
                });
                calcularZ();
              },
            ),

            // Dynamic input fields
            if (selectedOption != "En medio (z_1 ≤ Z ≤ z_2)")
              TextField(
                controller: sampleDiffController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Diferencia muestral (x̄₁ - x̄₂)'
                ),
                onChanged: (_) => calcularZ(),
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
                    onChanged: (_) => calcularZ(),
                  ),
                  TextField(
                    controller: sampleDiff2Controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Diferencia muestral 2 (x̄₁ - x̄₂)₂'
                    ),
                    onChanged: (_) => calcularZ(),
                  ),
                ],
              ),

            // Results display
            const SizedBox(height: 20),
            if (selectedOption == "En medio (z_1 ≤ Z ≤ z_2)" && resultadoZ1 != null && resultadoZ2 != null)
              Text(
                'z₁ = ${resultadoZ1!.toStringAsFixed(4)}, z₂ = ${resultadoZ2!.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 18),
              )
            else if (selectedOption != "En medio (z_1 ≤ Z ≤ z_2)" && resultadoZ != null)
              Text(
                'Z = ${resultadoZ!.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 18),
              ),
            
            if (resultadoProbabilidad != null)
              Text(
                selectedOption == "Menor P(Z ≤ z)"
                    ? 'P(Z ≤ z) = ${(resultadoProbabilidad! * 100).toStringAsFixed(2)}%'
                    : selectedOption == "Mayor P(z ≤ Z)"
                        ? 'P(z ≤ Z) = ${(resultadoProbabilidad! * 100).toStringAsFixed(2)}%'
                        : 'P(z₁ ≤ Z ≤ z₂) = ${(resultadoProbabilidad! * 100).toStringAsFixed(2)}%',
                style: const TextStyle(fontSize: 18),
              ),
            
            if (resultadoZ == null && resultadoZ1 == null && resultadoProbabilidad == null)
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