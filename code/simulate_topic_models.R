library(doParallel)
library(tm)
library(topicmodels)

trainSimTopicModels <- function(i) {  
  i <- as.integer(i)
  
  # Inspired by https://stackoverflow.com/a/14749552
  
  tryCatch({ 
    
    cols <- c("doc_id", "text")
    
    sim_f <- paste("ngrams_df_sim", i, ".csv", sep="")
    sim_data <- read.csv((sim_f), header = TRUE)
    sim_data <- sim_data[cols]
    
    # Convert to document-term matrix
    sim_corp <- Corpus(DataframeSource(sim_data))
    sim_dtm <- DocumentTermMatrix(sim_corp)
      
    # Simulated topic models to compare to preferred model (k = 15)
    
    k <- 15
    control_LDA_Gibbs = list(alpha = 50/k,
                             verbose = 0,
                             prefix = tempfile(),
                             save = 0,
                             keep = 0,
                             seed = 10683,
                             best = TRUE,
                             delta = 0.1,
                             iter = 5000,
                             burnin = 1000,
                             thin = 500,
                             initialize="random")
    sim_lda15 <- LDA(sim_dtm, k = k, method = "Gibbs",
                     control = control_LDA_Gibbs)
    
    outf = paste("sim", i, "_lda15gamma.txt", sep="")
    sim_lda15gamma <- sim_lda15@gamma
    sim_lda15gamma <- as.data.frame(sim_lda15gamma)
    write.csv(sim_lda15gamma, file = outf)
    
    outf = paste("sim", i, "_lda15beta.txt", sep="")
    sim_lda15beta <- sim_lda15@beta
    write.csv(sim_lda15beta, file = outf)
    
    lda15_inf <- posterior(sim_lda15)
    most_likely_topic_in_doc_15 <- topics(sim_lda15)
    likeliest_terms15 <- terms(sim_lda15, 10)
    
    outf <- paste("likeliest_terms_k15_sim", i, ".txt", sep="")
    write(likeliest_terms15, file = outf)
    
    outf <- paste("topic_probs_k15_sim", i, ".txt", sep="")
    write(lda15_inf$topics, file = outf)
    
    save(sim_lda15, file = paste("topicmodel_k15_sim", i, ".rda", sep=""))
    
    # Simulated topic models to compare to alternataive model (k = 35)
    
    k <- 35
    control_LDA_Gibbs = list(alpha = 50/k,
                             verbose = 0,
                             prefix = tempfile(),
                             save = 0,
                             keep = 0,
                             seed = 10683,
                             best = TRUE,
                             delta = 0.1,
                             iter = 5000,
                             burnin = 1000,
                             thin = 500,
                             initialize="random")
    sim_lda35 <- LDA(sim_dtm, k = k, method = "Gibbs",
                     control = control_LDA_Gibbs)
    
    outf = paste("sim", i, "_lda35beta.txt", sep="")
    sim_lda35beta <- sim_lda35@beta
    sim_lda35beta <- as.data.frame(sim_lda35beta)
    write.csv(sim_lda35beta, file = outf)
    
    outf = paste("sim", i, "_lda35gamma.txt", sep="")
    sim_lda35gamma <- sim_lda35@gamma
    write.csv(sim_lda35gamma, file = outf)
    
    lda35_inf <- posterior(sim_lda35)
    most_likely_topic_in_doc_35 <- topics(sim_lda35)
    likeliest_terms35 <- terms(sim_lda35, 10)
    
    outf <- paste("likeliest_terms_k35_sim", i, ".txt", sep="")
    write(likeliest_terms35, file = outf)
    
    outf <- paste("topic_probs_k35_sim", i, ".txt", sep="")
    write(lda35_inf$topics, file = outf)
    
    save(sim_lda35, file = paste("topicmodel_k35_sim", i, ".rda", sep=""))
    
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}

# Inspired by http://freerangestats.info/blog/2017/01/05/topic-model-cv

cluster <- makeCluster(detectCores(logical = TRUE) - 4)
registerDoParallel(cluster)

clusterEvalQ(cluster, {
  library(tm)
  library(topicmodels)
})

start_time <- proc.time()

system.time({
  result <- foreach(i=1:1000) %dopar% trainSimTopicModels(i)
})

proc.time() - start_time
