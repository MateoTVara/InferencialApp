// lib/utils/math_functions.dart
import 'dart:math';

double normalCDF(double z) {
  const double b1 =  0.319381530;
  const double b2 = -0.356563782;
  const double b3 =  1.781477937;
  const double b4 = -1.821255978;
  const double b5 =  1.330274429;
  const double p  =  0.2316419;
  const double c  =  0.3989422804014327;

  if (z >= 0.0) {
    double t = 1.0 / (1.0 + p * z);
    return 1.0 - c * exp(-z * z / 2.0) * t *
        (b1 + t * (b2 + t * (b3 + t * (b4 + t * b5))));
  } else {
    return 1.0 - normalCDF(-z);
  }
}
