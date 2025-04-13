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
  final TextEditingController mediaMuestral2Controller = TextEditingController();

  String selectedOption = "Menor P(Z ≤ z)";
  double? resultadoZ;
  double? resultadoZ1;
  double? resultadoZ2;
  double? resultadoProbabilidad;

  void calcularZ() {
    final double? mu = double.tryParse(mediaPoblacionalController.text);
    final double? sigma = double.tryParse(desviacionEstandarController.text);
    final int? n = int.tryParse(muestraController.text);
    final double? xBar1 = double.tryParse(mediaMuestralController.text);
    final double? xBar2 = double.tryParse(mediaMuestral2Controller.text);

    if (mu == null || sigma == null || n == null || n <= 0) {
      setState(() {
        resultadoZ = resultadoZ1 = resultadoZ2 = resultadoProbabilidad = null;
      });
      return;
    }

    if (selectedOption == "Menor P(Z ≤ z)") {
      if (xBar1 == null) {
        setState(() {
          resultadoZ = resultadoProbabilidad = null;
          resultadoZ1 = resultadoZ2 = null; // Clear other Z values
        });
        return;
      }
      final double z = (xBar1 - mu) / (sigma / sqrt(n));
      setState(() {
        resultadoZ = z;
        resultadoProbabilidad = normalCDF(z);
        resultadoZ1 = resultadoZ2 = null; // Clear other Z values
      });
    } 
    else if (selectedOption == "Mayor P(z ≤ Z)") {
      if (xBar1 == null) {
        setState(() {
          resultadoZ = resultadoProbabilidad = null;
          resultadoZ1 = resultadoZ2 = null; // Clear other Z values
        });
        return;
      }
      final double z = (xBar1 - mu) / (sigma / sqrt(n));
      setState(() {
        resultadoZ = z;
        resultadoProbabilidad = 1 - normalCDF(z);
        resultadoZ1 = resultadoZ2 = null; // Clear other Z values
      });
    } 
    else if (selectedOption == "En medio (z_1 ≤ Z ≤ z_2)") {
      if (xBar1 == null || xBar2 == null) {
        setState(() {
          resultadoZ1 = resultadoZ2 = resultadoProbabilidad = null;
          resultadoZ = null; // Clear single Z value
        });
        return;
      }
      final double z1 = (xBar1 - mu) / (sigma / sqrt(n));
      final double z2 = (xBar2 - mu) / (sigma / sqrt(n));
      final double lower = min(z1, z2);
      final double upper = max(z1, z2);
      setState(() {
        resultadoZ1 = z1;
        resultadoZ2 = z2;
        resultadoProbabilidad = normalCDF(upper) - normalCDF(lower);
        resultadoZ = null; // Clear single Z value
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
                  // Clear all results when changing option
                  resultadoZ = null;
                  resultadoZ1 = null;
                  resultadoZ2 = null;
                  resultadoProbabilidad = null;
                });
                calcularZ();
              },
            ),
            TextField(
              controller: mediaMuestralController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: selectedOption == "En medio (z_1 ≤ Z ≤ z_2)"
                    ? 'Media muestral 1 (x̄₁)'
                    : 'Media muestral (x̄)',
              ),
              onChanged: (_) => calcularZ(),
            ),
            if (selectedOption == "En medio (z_1 ≤ Z ≤ z_2)")
              TextField(
                controller: mediaMuestral2Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Media muestral 2 (x̄₂)'),
                onChanged: (_) => calcularZ(),
              ),
            const SizedBox(height: 20),
            // Safe display of Z values
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
            // Display probability
            if (resultadoProbabilidad != null)
              Text(
                selectedOption == "Menor P(Z ≤ z)"
                    ? 'P(Z ≤ z) = ${(resultadoProbabilidad! * 100).toStringAsFixed(4)}%'
                    : selectedOption == "Mayor P(z ≤ Z)"
                        ? 'P(z ≤ Z) = ${(resultadoProbabilidad! * 100).toStringAsFixed(3)}%'
                        : 'P(z₁ ≤ Z ≤ z₂) = ${(resultadoProbabilidad! * 100).toStringAsFixed(3)}%',
                style: const TextStyle(fontSize: 18),
              ),
            // Show error message if no valid results
            if (resultadoZ == null && resultadoZ1 == null && resultadoProbabilidad == null)
              const Text(
                'Ingresa todos los valores correctamente.',
                style: TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}