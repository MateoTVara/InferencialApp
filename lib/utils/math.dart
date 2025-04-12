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

double studentsTArea(double t, int df) {
  if (df <= 0) throw ArgumentError("Degrees of freedom must be positive");

  double tSquared = t * t;
  double x = df / (df + tSquared);
  double a = df / 2.0;
  double b = 0.5;

  double beta = incompleteBeta(x, a, b);

  return (t < 0) ? 0.5 * beta : 1.0 - 0.5 * beta;
}

double incompleteBeta(double x, double a, double b) {
  if (x < 0.0 || x > 1.0) throw ArgumentError("x must be in [0, 1]");
  if (a <= 0.0 || b <= 0.0) throw ArgumentError("a and b must be positive");

  double bt = exp(logGamma(a + b) - logGamma(a) - logGamma(b) + a * log(x) + b * log(1 - x));

  if (x < (a + 1) / (a + b + 2)) {
    return bt * betaContinuedFraction(x, a, b) / a;
  } else {
    return 1.0 - bt * betaContinuedFraction(1.0 - x, b, a) / b;
  }
}

double betaContinuedFraction(double x, double a, double b) {
  const double epsilon = 1e-15;
  const int maxIterations = 10000;

  double qab = a + b;
  double qap = a + 1.0;
  double qam = a - 1.0;
  double c = 1.0;
  double d = 1.0 - qab * x / qap;

  if (d.abs() < epsilon) d = epsilon;
  d = 1.0 / d;
  double h = d;

  for (int m = 1; m <= maxIterations; m++) {
    int m2 = 2 * m;
    double aa = m * (b - m) * x / ((qam + m2) * (a + m2));
    d = 1.0 + aa * d;
    if (d.abs() < epsilon) d = epsilon;
    c = 1.0 + aa / c;
    if (c.abs() < epsilon) c = epsilon;
    d = 1.0 / d;
    h *= d * c;

    aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2));
    d = 1.0 + aa * d;
    if (d.abs() < epsilon) d = epsilon;
    c = 1.0 + aa / c;
    if (c.abs() < epsilon) c = epsilon;
    d = 1.0 / d;
    double del = d * c;
    h *= del;

    if ((del - 1.0).abs() < epsilon) break;
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

void main() {
  int df = 15;
  double t = -3.65;
  double area = studentsTArea(t, df);
  print("Area for t=$t with df=$df: ${area.toStringAsFixed(6)}"); // ~0.0012
}