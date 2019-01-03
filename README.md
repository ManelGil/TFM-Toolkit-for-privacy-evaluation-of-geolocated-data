## Welcome to GitHub Pages

You can use the [editor on GitHub](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/edit/master/README.md) to maintain and preview the content for your website in Markdown files.

Whenever you commit to this repository, GitHub Pages will run [Jekyll](https://jekyllrb.com/) to rebuild the pages in your site, from the content in your Markdown files.

### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://help.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.



# Métodos de sanitización
## Perturbación
### Transformaciones primarias
- [Traslación](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/COORD_TRANSLATION.sql)
- [Escala](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/COORD_SCALING.sql)
- [Rotación](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/COORD_ROTATION.sql)

### Composición de transformaciones
- [Rotación 2º](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/TRANSF_ROT_2DEG.sql)
- [Rotación 5º](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/TRANSF_ROT_5DEG.sql)
- [Escala 1-0.7](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/TRANSF_SCL_1_07.sql)
- [Escala 1.05-0.9](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/TRANSF_SCL_105_09.sql)
- [Escala 0.95-0.95 + Rotación 1º](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/TRANSF_SCL_095_095_ROT_1DEG.sql)

## [Agregación](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/MICROAGGREGATION.sql)

## [Swapping](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/SWAPPING.sql)

# Ataques
## Sobre el dataset CabSpotting
- [Inferred homes]()
- [Begin-End](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/BEGIN_END.sql)
- [Stays](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/STAYS.sql)

## Sobre datasets sanitizados
### Rotación 2º
- [Inferred homes]()
- [Begin-End](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/BEGIN_END_ROT_2DEG.sql)
- [Stays](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/STAYS_ROT_2DEG.sql)

### Rotación 5º
- [Inferred homes]()
- [Begin-End](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/BEGIN_END_ROT_5DEG.sql)
- [Stays](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/STAYS_ROT_5DEG.sql)

### Escala 1-0.7
- [Inferred homes]()
- [Begin-End](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/BEGIN_END_SCL_1_07.sql)
- [Stays](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/STAYS_SCL_1_07.sql)

### Escala 1.05-0.9
- [Inferred homes]()
- [Begin-End](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/BEGIN_END_SCL_105_09.sql)
- [Stays](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/STAYS_SCL_105_09.sql)

### Escala 0.95-0.95 + Rotación 1º
- [Inferred homes]()
- [Begin-End](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/BEGIN_END_SCL_095_095_ROT_1DEG.sql)
- [Stays](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/STAYS_SCL_095_095_ROT_1DEG.sql)

### Agregación
- [Inferred homes]()
- [Begin-End](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/BEGIN_END_AGGREGATION.sql)
- [Stays](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/STAYS_TRACES_AGGREGATED.sql)

### Swapping
- [Inferred homes]()
- [Begin-End](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/BEGIN_END_SWAPPED_T10_D20.sql)
- [Stays](https://github.com/ManelGil/TFM-Toolkit-for-privacy-evaluation-of-geolocated-data/blob/master/STAYS_SWAPPED_T10_D20.sql)
