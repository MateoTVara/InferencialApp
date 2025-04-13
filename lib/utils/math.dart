// lib/utils/mathdart
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

double studentsTArea(double t, double df) {
  if (df <= 0) throw ArgumentError("Degrees of freedom must be positive");
  
  // Special cases for improved precision
  if (df == 1) {
    // Cauchy distribution
    return 0.5 + atan(t) / pi;
  }
  if (t == 0) {
    return 0.5;
  }

  final double tSquared = t * t;
  final double x = df / (df + tSquared);
  final double a = df / 2.0;
  final double b = 0.5;

  final double beta = incompleteBeta(x, a, b);
  return (t < 0) ? 0.5 * beta : 1.0 - 0.5 * beta;
}

double incompleteBeta(double x, double a, double b) {
  if (x < 0.0 || x > 1.0) throw ArgumentError("x must be in [0, 1]");
  if (a <= 0.0 || b <= 0.0) throw ArgumentError("a and b must be positive");

  final double bt = exp(
    logGamma(a + b) - 
    logGamma(a) - 
    logGamma(b) + 
    a * log(x) + 
    b * log(1 - x)  // Changed from log1p(-x)
  );

  if (x < (a + 1) / (a + b + 2)) {
    return bt * betaContinuedFractionLentz(x, a, b) / a;
  } else {
    return 1.0 - bt * betaContinuedFractionLentz(1.0 - x, b, a) / b;
  }
}

double betaContinuedFractionLentz(double x, double a, double b) {
  const double epsilon = 1e-30;
  const double fpmin = 1e-30;
  const int maxIterations = 100000;

  final double qab = a + b;
  final double qap = a + 1.0;
  final double qam = a - 1.0;
  
  double c = 1.0;
  double d = 1.0 / (1.0 - qab * x / qap).clampAbove(fpmin);
  double h = d;
  
  for (int m = 1; m <= maxIterations; m++) {
    final int m2 = 2 * m;
    final double aa1 = m * (b - m) * x / ((qam + m2) * (a + m2));
    final double aa2 = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2));

    // First step
    d = 1.0 + aa1 * d;
    c = 1.0 + aa1 / c;
    d = 1.0 / d.clampAbove(fpmin);
    h *= d * c;

    // Second step
    d = 1.0 + aa2 * d;
    c = 1.0 + aa2 / c;
    d = 1.0 / d.clampAbove(fpmin);
    final double del = d * c;
    h *= del;

    // Enhanced convergence check (relative error)
    if ((del - 1.0).abs() < 1e-15) break;
  }
  return h;
}

double logGamma(double x) {
  const List<double> cof = [
    57.1562356658629235,
    -59.5979603554754912,
    14.1360979747417471,
    -0.491913816097620199,
    0.339946499848118887e-4,
    0.465236289270485756e-4,
    -0.983744753048795646e-4,
    0.158088703224912494e-3,
    -0.210264441724104883e-3,
    0.217439618115212643e-3,
    -0.164318106536763890e-3,
    0.844182239838527433e-4,
    -0.261908384015814087e-4,
    0.368991826595316234e-5
  ];

  if (x <= 0) {
    throw ArgumentError("x must be positive");
  }

  double y = x;
  double tmp = x + 5.24218750000000000;
  tmp = (x + 0.5) * log(tmp) - tmp;
  double ser = 0.999999999999997092;

  for (int j = 0; j < cof.length; j++) {
    y += 1.0;
    ser += cof[j] / y;
  }

  return tmp + log(2.5066282746310005 * ser / x);
}

extension on double {
  double clampAbove(double minimum) => this < minimum ? minimum : this;
}