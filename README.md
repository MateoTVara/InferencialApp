# 📊 InferStat – Statistical Inference Calculator (Demo)  

A **demo** mobile app developed in Flutter for performing **statistical inference** calculations quickly and easily.  
Includes tools for estimation and hypothesis testing with known and unknown variances.  

---  

## ✨ Features  
- **Mean and standard deviation calculations** for one or two samples  
- Support for cases with:  
  - **Known variance**  
  - **Unknown variance**  
- Intuitive tab-based interface for different statistical methods  
- Responsive design for mobile devices  
- **About page** with app information  

---  

## 📂 Project Structure  
```
lib/
├── utils/
│ └── math.dart                         # Statistical functions
├── views/
│ ├── about_page.dart                   # About screen
│ ├── sddm_with_known_variance.dart     # Two-sample (known σ²)
│ ├── sddm_with_unknown_variance.dart   # Two-sample (unknown σ²)
│ ├── sdm_with_known_variance.dart      # One-sample (known σ²)
│ ├── sdm_with_unknown_variance.dart    # One-sample (unknown σ²)
│ └── views.dart                        # View exports
└── main.dart                           # App entry point
```


---  

## 📜 License  

`MIT License` - Free for educational and demonstrative use.  
Modifications and distributions are permitted.  

> Note: This is a demo version with limited functionality.  

---  
