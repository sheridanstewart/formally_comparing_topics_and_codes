library(doParallel)
library(tm)
library(topicdoc)
library(topicmodels)
library(ggplot2)

# Ingest corpus
f <- "ngrams_df.csv"
data <- read.csv((f), header = TRUE)
cols <- c("doc_id", "text")
data <- data[cols]

# Convert to document-term matrix
corp <- Corpus(DataframeSource(data))
dtm <- DocumentTermMatrix(corp)

# Inspired by http://freerangestats.info/blog/2017/01/05/topic-model-cv

seed <- 10683 # first random seed from random.org
folds <- 5
n <- nrow(dtm)
splitfolds <- sample(1:folds, n, replace = TRUE)
candidate_k <- c(3:100) # candidates for how many topics

k = 3
control_LDA_Gibbs = list(alpha = 50/k,
                         # estimate.alpha = TRUE, # TRUE by default
                         # estimate.beta = TRUE, # TRUE by default
                         verbose = 0,
                         prefix = tempfile(),
                         save = 0,
                         keep = 0,
                         seed = seed,
                         best = TRUE,
                         delta = 0.1,
                         iter = 5000,
                         burnin = 1000,
                         thin = 500,
                         initialize="random")

cluster <- makeCluster(detectCores(logical = TRUE) - 2)
registerDoParallel(cluster)

clusterEvalQ(cluster, {
  library(topicmodels)
  library(topicdoc)
})

clusterExport(cluster, c("dtm", "candidate_k", "folds", "splitfolds", "n", "seed", "control_LDA_Gibbs"))

system.time({
  results <- foreach(j = 1:length(candidate_k), .combine = rbind) %dopar%{
    
    k <- candidate_k[j]
    
    results_1k <- matrix(0, nrow = folds, ncol = 6)
    colnames(results_1k) <- c("k", "perplexity", "mean_exclusivity", "median_exclusivity", "mean_coherence_train", "median_coherence_train")
    for(i in 1:folds){
      train_set <- dtm[splitfolds != i , ]
      valid_set <- dtm[splitfolds == i, ]
      
      control_LDA_Gibbs$alpha <- 50/k
      
      fitted <- LDA(train_set, k = k, method = "Gibbs",
                    control = control_LDA_Gibbs)
      
      median_coh_train <- median(topic_coherence(fitted, train_set))
      median_exc <- median(topic_exclusivity(fitted))
      
      mean_coh_train <- mean(topic_coherence(fitted, train_set))
      mean_exc <- mean(topic_exclusivity(fitted))
      
      results_1k[i,] <- c(k, perplexity(fitted, newdata = valid_set, estimate_theta=TRUE, use_theta = TRUE), mean_exc, median_exc, mean_coh_train, median_coh_train)
    }
    return(results_1k)
  }
})
stopCluster(cluster)

# convert results from all 98 models (k=3 to k=100) to a data frame
results_df <- as.data.frame(results)

# create new variables by standardizing existing variables
results_df$mean_coh_std <- scale(results_df$mean_coherence_train)
results_df$median_coh_std <- scale(results_df$median_coherence_train)

results_df$mean_exc_std <- scale(results_df$mean_exclusivity)
results_df$median_exc_std <- scale(results_df$median_exclusivity)

results_df$perplexity_std <- scale(results_df$perplexity)

# set colors for changing appearance of plots including coherence, exclusivity, and perplexity
coh_color = "blue"
exc_color = "orange"
perp_color = "green"

# Setting things up to plot CHANGE in coherence, exclusivity, and perplexity from k-1 to k for values of k in [3,100]
change_in_coherence = c()
change_in_exclusivity = c()
change_in_perplexity = c()

for (i in c(4:100)) {
  mini <- results_df[which(results_df$k==i),]
  perp <- median(mini$perplexity_std)
  coh <- median(mini$mean_coh_std)
  exc <- median(mini$mean_exc_std)
  
  i_prev <- i-1
  mini_prev <- results_df[which(results_df$k==i_prev),]
  perp_prev <- median(mini_prev$perplexity_std)
  coh_prev <- median(mini_prev$mean_coh_std)
  exc_prev <- median(mini_prev$mean_exc_std)
  
  perp_dif <- perp-perp_prev
  coh_dif <- coh-coh_prev
  exc_dif <- exc-exc_prev
  
  change_in_perplexity <- append(change_in_perplexity, perp_dif)
  change_in_coherence <- append(change_in_coherence, coh_dif)
  change_in_exclusivity <- append(change_in_exclusivity, exc_dif)
}

# Create a new data frame using the new variables
k <- c(4:100) # first k is 4 so it can be compared to k-1 (3)
change_df <- as.data.frame(k)
change_df$change_in_perplexity <- change_in_perplexity
change_df$change_in_exclusivity <- change_in_exclusivity
change_df$change_in_coherence <- change_in_coherence

# Figure 1. Tradeoffs among coherence, exclusivity, and perplexity over number of topics.

line_pal = c("#1b9e77", "#d95f02", "#7570b3")

coh_vals = results_df$mean_coh_std
n_ = length(coh_vals)
coh_labels = rep.int("Coherence", times=n_)

exc_vals = results_df$mean_exc_std
exc_labels = rep.int("Exclusivity", times=n_)

perp_vals = results_df$perplexity_std
perp_labels = rep.int("Perplexity", times=n_)

std_vals = coh_vals
std_vals = append(std_vals, exc_vals)
std_vals = append(std_vals, perp_vals)

labels = coh_labels
labels = append(labels, exc_labels)
labels = append(labels, perp_labels)

ks = results_df$k
ks = append(ks, results_df$k)
ks = append(ks, results_df$k)

length(std_vals)
length(labels)
length(ks)

summary(std_vals)
table(labels)

plot_std <- data.frame(std_Vals = std_vals, Measures = as.factor(labels), k = ks)

p <- ggplot(plot_std, aes(x=k, y=std_vals, group=Measures, color=Measures)) +
  geom_smooth(aes(linetype=Measures), se=TRUE, method = "loess", formula = "y ~ x",
              span=1, fill="gray85") +
  labs(x = "Number of Topics (k)", y = "Standardized Value") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) +
  ggplot2::annotate("rect", xmin = 15, xmax = 35, ymin = -Inf, ymax = Inf, 
                    alpha = .20, fill = "grey", color="transparent") +
  scale_color_manual(values=line_pal) +
  theme(text = element_text(family = "Times"))
p

ggsave("comparing_topic_models_qual_coding_figure1.tiff",dpi=300)

# Figure 2. Change in coherence, exclusivity, and perplexity from k − 1 to k Topics.

coh_change_vals = change_df$change_in_coherence
n_ = length(coh_change_vals)
coh_labels = rep.int("Coherence", times=n_)

exc_change_vals = change_df$change_in_exclusivity
exc_labels = rep.int("Exclusivity", times=n_)

perp_change_vals = change_df$change_in_perplexity
perp_labels = rep.int("Perplexity", times=n_)

std_change_vals = coh_change_vals
std_change_vals = append(std_change_vals, exc_change_vals)
std_change_vals = append(std_change_vals, perp_change_vals)

labels = coh_labels
labels = append(labels, exc_labels)
labels = append(labels, perp_labels)

ks = change_df$k
ks = append(ks, change_df$k)
ks = append(ks, change_df$k)

length(std_change_vals)
length(labels)
length(ks)

summary(std_change_vals)
table(labels)

plot_change_std <- data.frame(std_change_vals = std_change_vals, Measures = as.factor(labels), k = ks)

p_change <- ggplot(plot_change_std, aes(x=k, y=std_change_vals, group=Measures, color=Measures)) +
  geom_smooth(aes(linetype=Measures), se=FALSE, method = "loess", formula = "y ~ x",
              span=1) +
  labs(x = "Number of Topics (k)", y = "Change in Standardized Value (k-1 to k)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) +
  ggplot2::annotate("rect", xmin = 15, xmax = 35, ymin = -Inf, ymax = Inf, 
                    alpha = .20, fill = "grey", color="transparent") +
  scale_color_manual(values=line_pal) +
  theme(text = element_text(family = "TT Times New Roman"))
p_change

ggsave("comparing_topic_models_qual_coding_figure2.tiff",dpi=300)
