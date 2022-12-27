# Code for “Formally Comparing Topic Models and Human-Generated Qualitative Coding of Physician Mothers’ Experiences of Workplace Discrimination”

This repository contains the code used in “Formally Comparing Topic Models and Human-Generated Qualitative Coding of Physician Mothers’ Experiences of Workplace Discrimination” by Adam S. Miner, Sheridan A. Stewart, Meghan C. Halley, Laura K. Nelson, and Eleni Linos. Please refer to [the original paper](https://doi.org/10.1177/20539517221149106) in *Big Data & Society*. In this paper, we evaluate whether topic models identify themes similar to those found by human coders in [a prior qualitative analysis](https://doi.org/10.1136/bmj.k4926) of physician mothers’ experiences of workplace discrimination.

## Guide to the Code

### Setup: Preprocessing and Simulations

``preprocessing.ipynb`` contains the Python code used to preprocess the corpus and shows connections to Table 1 in the paper.

``narrowing_range_of_model_sizes.R``<sup>1</sup> contains the R code used to visualize tradeoffs between coherence, exclusivity, and perplexity for topic models of different sizes to identify a narrower range of models to inspect more closely. This file produces Figures 1 and 2.

``train_topic_models.R`` contains the R code for training the topic models that the authors inspected more closely in order to choose the preferred and alternative models.

``view_top_terms_and_documents.ipynb`` contains the Python code used to produce a document with the top terms and documents associated with each topic for evaluating the quality of the topics and labeling them.

``simulate_corpora.ipynb`` contains the Python code for creating synthetic corpora based on the real corpus size, the empirical distribution of document lengths, and the empirical distribution of word frequencies.

``simulate_topic_models.R``<sup>1,2</sup> contains the R code for training topic models on each synthetic corpus.

``merge_dataframes.ipynb`` contains the Python code for merging a dataframe with the qualitative codes with dataframes with topic probabilities at the document level.

``distributions_of_simulated_tjur_r2.ipynb`` contains the Python code for estimating distributions of [coefficients of discrimination (Tjur R2)](https://doi.org/10.1198/tast.2009.08210) to which the real estimates can be compared.

### Comparing the Original Qualitative Coding to the Preferred and Alternative Topic Models

``figures3_and_6_comparing_topic_to_qualitative_codes.ipynb`` contains the Python code for conducting hypothesis tests comparing the topics in the preferred model (k=15) and alternative model (k=35), as well as the full models, to each code applied in the original qualitative analysis. The hypothesis tests involve comparing each real estimate to a distribution of simulated estimates from the topic models trained on synthetic corpora. This notebook also produces Figures 3 and 6 as well as Table 3.

### Comparing the Preferred and Alternative Topic Models to One Another to Assess Robustness to Model Size

``figure4_comparing_topic_models.ipynb`` contains the Python code for directly comparing the preferred (k=15) and alternative (k=35) topic models using the beta distributions. This notebook produces Figure 4.

``figure5_document_level_comparisons.ipynb`` contains the Python code for directly comparing the preferred (k=15) and alternative (k=35) topic models using the topic probabilities at the document level (i.e., the gamma distributions). This notebook produces Figure 5.

<sup>1</sup>These scripts drew inspiration from [a blog post](http://freerangestats.info/blog/2017/01/05/topic-model-cv) on the *free range statistics* blog by Peter Ellis.

<sup>2</sup>This script additionally drew inspiration from a Stack Overflow post found [here](https://stackoverflow.com/a/14749552).


