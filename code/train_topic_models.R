library(tm)
library(topicmodels)

# Ingest corpus
f <- "ngrams_df.csv"
data <- read.csv((f), header = TRUE)
cols <- c("doc_id", "text")
data <- data[cols]

# Convert to document-term matrix
corp <- Corpus(DataframeSource(data))
dtm <- DocumentTermMatrix(corp)

seed <- 10683 # first random seed from random.org

# Train model for k=15
k <- 15
control_LDA_Gibbs = list(alpha = 50/k,
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

lda15 <- LDA(dtm, k = k, method = "Gibbs",
             control = control_LDA_Gibbs)

lda15_inf <- posterior(lda15)
most_likely_topic_in_doc_15 <- topics(lda15)
most_likely_terms_in_topic15 <- terms(lda15, 10)
likeliest_terms15 <- most_likely_terms_in_topic15
write(likeliest_terms15, file = "most_likely_terms15.txt")
write(lda15_inf$topics, file = "topic_probs15.txt")
lda15gamma <- lda15@gamma
lda15gamma <- as.data.frame(lda15gamma)
write.csv(lda15gamma, file = "lda15gamma.txt")
lda15beta <- lda15@beta
write.csv(lda15beta, file = "lda15beta.txt")


# Train model for k=25
k <- 25
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

lda25 <- LDA(dtm, k = k, method = "Gibbs",
             control = control_LDA_Gibbs)

lda25_inf <- posterior(lda25)
most_likely_topic_in_doc_25 <- topics(lda25)
most_likely_terms_in_topic25 <- terms(lda25, 10)
likeliest_terms25 <- most_likely_terms_in_topic25
write(likeliest_terms25, file = "most_likely_terms25.txt")
write(lda25_inf$topics, file = "topic_probs25.txt")
lda25gamma <- lda25@gamma
lda25gamma <- as.data.frame(lda25gamma)
write.csv(lda25gamma, file = "lda25gamma.txt")
lda25beta <- lda25@beta
write.csv(lda25beta, file = "lda25beta.txt")


# Train model for k=35
k <- 35
control_LDA_Gibbs = list(alpha = 50/k,
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

lda35 <- LDA(dtm, k = k, method = "Gibbs",
             control = control_LDA_Gibbs)

lda35_inf <- posterior(lda35)
most_likely_topic_in_doc_35 <- topics(lda35)
most_likely_terms_in_topic35 <- terms(lda35, 10)
likeliest_terms35 <- most_likely_terms_in_topic35
write(likeliest_terms35, file = "most_likely_terms35.txt")
write(lda35_inf$topics, file = "topic_probs35.txt")
lda35gamma <- lda35@gamma
lda35gamma <- as.data.frame(lda35gamma)
write.csv(lda35gamma, file = "lda35gamma.txt")
lda35beta <- lda35@beta
write.csv(lda35beta, file = "lda35beta.txt")