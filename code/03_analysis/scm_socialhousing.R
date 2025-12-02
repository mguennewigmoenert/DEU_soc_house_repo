#Restore libraries from lock file


#renv::restore()
#install.packages("devtools")
#devtools::install_github('ebenmichael/augsynth')
#install.packages("MASS",repos="http://lib.stat.cmu.edu/R/CRAN")
#install.packages("Rcpp", repos=c("https://RcppCore.github.io/drat", "https://cloud.r-project.org"))
#install.packages("LowRankQP")
#install.packages("scpi")
#devtools::install_github('xuyiqing/gsynth')
#install.packages('gsynth', type = 'source')
#install.packages("patchwork")


library(LowRankQP)
library(devtools)
library(zoo)
library(haven)
library(data.table)
library(scpi)
library(augsynth)
library(gsynth)
library(plyr)
library(purrr)
library(dplyr)
library(patchwork)
library(tidyr)
library(reshape2)
library(ggplot2)
library(tibble)
library(CVXR)
library(Rmpfr)

rm(list=ls(all=TRUE))
#setwd('')


##############################################################################################################

#Preparing the data 

##############################################################################################################

# Before running the code in stata I will create 
# Use the options from the Schularick Paper (Start with the two large events in 2012)
cov.adj  <- NULL 
features <- NULL  
constant <- FALSE 
rho      <- 'type-1'                                      
rho.max  <- 2                                            
u.order  <- 0                                            
e.order  <- 0                                           
u.lags   <- 0                                             
e.lags   <- 0                                          
u.sigma  <- "HC1"                                          
e.sigma  <- "HC1"                                         
u.missp  <- T                                           
u.alpha  <- 0.1                                           
e.alpha  <- 0.1                                         
cointegrated.data <- TRUE                                
cores    <- 4
sims     <- 200                                      
e.method = "gaussian"                                     
w.constr <- list(lb = 0, dir = "==", p = "no norm", Q = 1)
  #list(lb = 0, dir = "==", p = "L1", Q = 1)
  # list(name = "simplex", Q = 1)
  
# We have 42 units which were treated inbetween 2011 and 2017 
# It is also a bit unclear how we should deal with multiple treatments 


#year <- c(2017, 2014, 2016, 2011, 2011, 2018, 2018, 2017, 2017, 2017, 2016, 2017, 2018, 2016, 2017, 2017, 2014, 2012, 2017, 2017, 2016, 2017, 2014, 2015, 2017, 2013, 2012, 2015, 2016, 2018, 2017, 2018, 2014, 2016, 2011, 2014, 2017, 2015, 2011, 2011, 2012, 2015) 
#id <-  c(1100103, 1100104, 1200627, 1400938, 1400940, 2100101, 2100104, 3200308, 3200310, 3300411, 3300413, 3400618, 4300622, 5100206, 5100208, 5100209, 5200423, 5200526, 5200527, 5300737, 6100204, 6100205, 6200311, 6300630, 7501134, 7601238, 7601340, 7601545, 8100207, 8100419, 8100520, 8200728, 8200831, 8200833, 8300934, 8301036, 8401246, 10200421, 12200307, 12200309, 12601032, 12601133)

# Only units treated until 2014 
#year <- c(2014, 2011, 2011, 2014, 2012, 2014, 2013, 2012, 2014, 2011, 2014, 2011, 2011, 2012)
#id <- c(1100104, 1400938, 1400940, 5200423, 5200526, 6200311, 7601238, 7601340, 8200831, 8300934, 8301036, 12200307, 12200309, 12601032)

#id<- c(1100104, 5200423, 6200311, 8200831, 8301036)
# year <-c(2014, 2014, 2014, 2014)

# Only units without multiple treatments (34)
#year <- c(2017, 2014, 2016, 2011, 2011, 2018, 2017, 2017, 2016, 2017, 2018, 2017, 2017, 2017, 2016, 2017, 2014, 2015, 2014, 2014, 2017, 2013, 2015, 2018, 2017, 2018, 2014, 2016, 2017, 2018, 2011, 2016, 2011, 2015)
#id <- c(1100103, 1100104, 1200627, 1400938, 1400940, 2100101, 3200308, 3300411, 3300413, 3400618, 4300622, 5100208, 5100209, 5300737, 6100204, 6100205, 6200311, 6300630, 7400822, 7501032, 7501134, 7601238, 7601339, 8100419, 8100520, 8200728, 8200831, 8200833, 8401246,11200514, 12200307, 12200308, 12200309, 12601133)
# access Max
data <- read_dta("/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/Housing Project/data/temp/synthetic_control_prepped_population.dta")

autoring <- read_dta("/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/Housing Project/data/temp/autoring_lor.dta")

# make sure join column is numeric
autoring$PLR_ID = as.numeric(autoring$PLR_ID)

# merge core periphery data
data = merge(data, autoring[c("auto_ring", "PLR_ID")], by="PLR_ID", all.x=T)


# get list with all treated PLR's
# Obtain a list of all unique group IDs
id <- data %>%
  filter(gen_treated==1 & is.na(auto_ring)
  ) %>%
  select(plr_code) %>%     # Select the group_id column
  distinct() %>%           # Keep only distinct (unique) group IDs
  pull(plr_code)         # Extract the group_id column as a vector

# Convert to a list (optional, if needed as a list)
id <- c(id)

data_max <- data.frame(fread("/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/Housing Project/data/temp/scm_prep_max.csv"))

year <- data_max %>%
  filter(treated==1
         & is.na(auto_ring) # adjust for within or outside A100; not either 1 or NA
  ) %>%
  group_by(PLR_ID) %>%                 # Group by group_id
  summarize(fy_treat = unique(fy_treat0)) %>%  # Extract unique values as a list
  ungroup() %>% 
  dplyr::select(fy_treat)

# Convert to a list (optional, if needed as a list)
year = unlist(c(year))

# Obtain unique values of `other_var` for each `group_id`
year <- data_max %>%
  filter(gen_treated==1 & auto_ring==1 & min_treatment<2019
  ) %>%
  group_by(plr_code) %>%                 # Group by group_id
  summarize(year = unique(min_treatment)) %>%  # Extract unique values as a list
  ungroup() %>% 
  dplyr::select(year)

# Convert to a list (optional, if needed as a list)
year = unlist(c(year))


# Only units without multiple treatments (32), excluding the four largest changes (larger than 40 percent)
year <- c(2017, 2014, 2016, 2011, 2011, 2018, 2017, 2017, 2016, 2017, 2018, 2017, 2017, 2017, 2016, 2017, 2014, 2015, 2014, 2014, 2017, 2013, 2015, 2018, 2018, 2014, 2016, 2017, 2018,  2016, 2011, 2015)
id <- c(1100103, 1100104, 1200627, 1400938, 1400940, 2100101, 3200308, 3300411, 3300413, 3400618, 4300622, 5100208, 5100209, 5300737, 6100204, 6100205, 6200311, 6300630, 7400822, 7501032, 7501134, 7601238, 7601339, 8100419, 8200728, 8200831, 8200833, 8401246, 11200514,  12200308, 12200309, 12601133)


s <- data.frame(id,year)
s$case <- paste(as.character(s$id), as.character(s$year), sep=".")
s$final <- paste("_", as.character(s$case))

s |>
  filter(year < 2019) -> s

for (k in 1:length(s$id)) {
  
  #k <- 32
  options(warn=0)
  Oldc = s$id[k]  
  Trea = s$id[k]
  Year = s$year[k]
  Case = s$case[k]
  Set = s$final[k]
  control = s$control[k]
  
  # access Max
  data <- read_dta("/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/Housing Project/data/temp/synthetic_control_prepped_population.dta")

    # data <- read_dta("C:/Users/laura/Desktop/SocialHousing/data/temp/synthetic_control_prepped_population.dta")

  data <- data[which(data$jahr >=Year- 4 & data$jahr <=Year+4),]
  taker <- data %>% dplyr::filter(data$plr_code == Oldc & treat == Oldc)
  donors <- data %>% dplyr::filter(data$plr_code != Oldc & treat == Oldc)
  # Kick out all other observations that also had a huge change in social housing that year  
  #donors <- donors  %>% dplyr::mutate(simul = ifelse(min_treatment == Year, 1,0))
  # Maximum of this 
  #donors <- donors %>% group_by(plr_code) %>% dplyr::mutate(msimul = max(as.numeric(simul))) 
  # Only use PLRs which did not have a large change in social housing during the observation period
  donors <- donors %>%  dplyr::filter(donor == 1)
  #donors <- donors %>%  dplyr::filter(plr_code == 1100311 | plr_code == 1100414 | plr_code == 1401049 | plr_code == 2100106)
  # Drop Variables simul msimul
  #donors = subset(donors, select = -c(simul,msimul))
  data <- rbind(taker, donors)
  data <- data %>% group_by(plr_code) %>% dplyr::filter(all(!is.na(sqm_rent_avg) | plr_code==Oldc ))
  data$ln_sqm_rent_avg = log(data$sqm_rent_avg)
  
  # Subset of all variables in treatment year
  tysub <- data[data$jahr == Year,]

  # Only keep certain variables 
  # tysub <- dplyr::select(tysub, PLR_ID, plr_code, sqm_rent_avg)
  tysub <- dplyr::select(tysub, PLR_ID, plr_code, ln_sqm_rent_avg)
  # Rename variable 
  # names(tysub)[names(tysub) == 'sqm_rent_avg'] <- 'isqm_rent_avg'
  names(tysub)[names(tysub) == 'ln_sqm_rent_avg'] <- 'iln_sqm_rent_avg'

  # Merge the value of Qm Miete Kalt to the data frame
  data <- merge(data, tysub)
  # Generate new variables, t indicates time frame  
  #data <- data %>% group_by(plr_code) %>% dplyr::mutate(d = sqm_rent_avg, t = jahr-Year+4)
  # data <- data %>% group_by(plr_code) %>% dplyr::mutate(d = sqm_rent_avg - isqm_rent_avg, t = jahr-Year+4)
  data <- data %>% group_by(plr_code) %>% dplyr::mutate(d = ln_sqm_rent_avg - iln_sqm_rent_avg, t = jahr-Year+4)
  
  # Generate new index 
  period.pre  <- seq(from = 0, to = 4, by = 1) 
  period.post <- (5:8)
  
  # Treatment Indicator 
  #data <- data  %>% dplyr::mutate(treat = ifelse(plr_code == 5200526, 1,0))
  # Implement the Synthetic Control command 
  df  <- scdata(df = data,  features = features, constant = constant, cov.adj = cov.adj,  cointegrated.data = cointegrated.data, id.var = "plr_code" ,  
                time.var = "t", outcome.var = "d", period.pre = period.pre, period.post = period.post, unit.tr = Trea, unit.co = setdiff(unique(data$plr_code),Trea))  
  
  # Get the result
  result <-  scpi(data = df, u.order = u.order, u.lags = u.lags, u.sigma = u.sigma, u.missp = u.missp,  e.order = e.order, e.lags = e.lags,  
                  u.alpha = u.alpha, e.alpha = e.alpha, rho = rho,  rho.max = rho.max, sims = sims, w.constr = w.constr, cores = cores, e.method = e.method)
  #result <-  scpi(data = df, 
  #                u.sigma = u.sigma, 
  #                cores = cores, 
  #                u.alpha = u.alpha, 
  #                e.alpha = e.alpha, 
  #                e.method = e.method)

  # All estimates for the fitted outcome variable in one vector 
  y.fit <- rbind(result$est.results$Y.pre.fit, result$est.results$Y.post.fit)
  # Combine everything in one data frame 
  yfit    <- data.frame(t = 1:9, yfit = c(y.fit))
  # Actual observations 
  y.act <- rbind(result$data$Y.pre, result$data$Y.post)
  f<- c(period.pre, period.post)
  # Combine all the observations into one vector 
  yact    <- data.frame(t = 1:9, yact = c(y.act), case = Case)
  # Merge everything together 
  ys   <-  merge(yact, yfit, by.x="t", by.y="t", all = TRUE)
  # Get the Inference, since there seems to be some difficulty with SC Method, for now 
  scl.gauss  <- result$inference.results$CI.all.gaussian[, 1, drop = FALSE]
  scr.gauss  <- result$inference.results$CI.all.gaussian[, 2, drop = FALSE]
  scl.insample  <- result$inference.results$CI.in.sample[, 1, drop = FALSE]
  scr.insample  <- result$inference.results$CI.in.sample[, 2, drop = FALSE]
  cis <- data.frame(t = c(period.post), sclinsample = c(scl.insample), scrinsample = c(scr.insample),  sclgauss = c(scl.gauss), scrgauss = c(scr.gauss))
  series  <-  merge(ys, cis, by.x="t", by.y="t", all = TRUE)
  #series <-(ys)
  assign(paste(Set), series) 
  }
  
  dfs <- lapply(ls(pattern="^_"), function(x) get(x))
  finaldata <- rbindlist(dfs, fill = TRUE)
  #finaldata <- rbindlist(dfs)
  # Set T variable from -15 to 15 
  #finaldata <- finaldata %>% group_by(case) %>% dplyr::mutate(ti = t - 3)
  finaldata <- finaldata %>% group_by(case)  %>% dplyr::mutate(ti = t - 5)
  # Normalize to 0 
  finaldata$sclinsample[finaldata$ti == 0] <- 0
  finaldata$scrinsample[finaldata$ti == 0] <- 0
  finaldata$sclgauss[finaldata$ti == 0] <- 0
  finaldata$scrgauss[finaldata$ti == 0] <- 0
  
  finaldata$all <- 1
  
  dataforplot_all <- Reduce(function(x, y) merge(x, y, all=TRUE), list(ddply(finaldata, .(ti), summarise, yfit_all=mean(yfit[all==1], na.rm=TRUE)), 
                                                                       ddply(finaldata, .(ti), summarise, yact_all=mean(yact[all==1], na.rm=TRUE)), 
                                                                       ddply(finaldata, .(ti), summarise, scrinsample_all=mean(scrinsample[all==1], na.rm=TRUE)),
                                                                       ddply(finaldata, .(ti), summarise, sclinsample_all=mean(sclinsample[all==1], na.rm=TRUE)), 
                                                                       ddply(finaldata, .(ti), summarise, scrgauss_all=mean(scrgauss[all==1], na.rm=TRUE)),
                                                                       ddply(finaldata, .(ti), summarise, sclgauss_all=mean(sclgauss[all==1], na.rm=TRUE)))) 
  
  
  
  # Generate the General Plots 
  
  ggplot(data = dataforplot_all) + geom_line(aes(y=yfit_all, x=ti, colour = "Untreated avg.", linetype= "Untreated avg.", size= "Untreated avg."))+
    geom_line(aes(y=yact_all, x=ti, colour = "Treated avg.",  linetype="Treated avg.", size="Treated avg."))+    scale_colour_manual(name='', values=c("Treated avg." = "blue", "Untreated avg." = "blue", "90% CI (out-of-sample uncertainty)" = "grey95")) +
    geom_line(aes(x=ti, y = sclgauss_all, color = "90% CI (out-of-sample uncertainty)", linetype = "90% CI (out-of-sample uncertainty)", size = "90% CI (out-of-sample uncertainty)")) +
    geom_line(aes(x=ti, y = scrgauss_all, color = "90% CI (out-of-sample uncertainty)", linetype = "90% CI (out-of-sample uncertainty)", size = "90% CI (out-of-sample uncertainty)")) +
    scale_fill_manual(name = '',  values=c("Treated avg." = "blue", "Untreated avg." = "blue", "90% CI (out-of-sample uncertainty)" = "grey95"))+
    scale_linetype_manual(name='', values=c("Treated avg." = "solid", "Untreated avg." = "longdash", "90% CI (out-of-sample uncertainty)" = "solid"))+
    scale_size_manual(name='', values=c("Treated avg." = 0.4, "Untreated avg." = 0.4)) +
    theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + labs(title = "Large Change in Social Housing", x = "", y = "") + theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    geom_vline(xintercept = 0, linetype="dashed",size=0.2) +  geom_hline(yintercept = 0, linetype="solid", color ="red", size=0.2) 

  
  
  # Mock Plot 
    ggplot(data = dataforplot_all) +geom_ribbon(aes(ymin=sclgauss_all, ymax=scrgauss_all, x=ti, fill="90% CI (out-of-sample uncertainty)"), alpha = 1) +
    geom_line(aes(x=ti, y = sclgauss_all, color = "90% CI (out-of-sample uncertainty)", linetype = "90% CI (out-of-sample uncertainty)", size = "90% CI (out-of-sample uncertainty)")) +
    geom_line(aes(x=ti, y = scrgauss_all, color = "90% CI (out-of-sample uncertainty)", linetype = "90% CI (out-of-sample uncertainty)", size = "90% CI (out-of-sample uncertainty)")) +
    geom_line(aes(y=yfit_all, x=ti, colour = "Untreated avg.", linetype= "Untreated avg.", size= "Untreated avg."))+
    geom_line(aes(y=yact_all, x=ti, colour = "Treated avg.",  linetype="Treated avg.", size="Treated avg."))+
    scale_colour_manual(name='', values=c("Treated avg." = "blue", "Untreated avg." = "blue", "90% CI (out-of-sample uncertainty)" = "grey95")) +
    scale_fill_manual(name = '',  values=c("Treated avg." = "blue", "Untreated avg." = "blue", "90% CI (out-of-sample uncertainty)" = "grey95")) +
    scale_linetype_manual(name='', values=c("Treated avg." = "solid", "Untreated avg." = "longdash", "90% CI (out-of-sample uncertainty)" = "solid")) +
    scale_size_manual(name='', values=c("Treated avg." = 0.4, "Untreated avg." = 0.4, "90% CI (out-of-sample uncertainty)" = 0.4)) +
    theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    scale_x_continuous(breaks=c(-4,-2,0,2,4), expand=c(0.02,0.02))+
    # scale_y_continuous(limits = c(-0.40, 0.60), breaks = c(-0.15,-0.5,0,0.15,0.3,0.45), labels = format(c("-0.15","-0.5","0","0.15","0.30","0.45"),nsmall=1), expand=c(0.02,0.02))+ 
    labs(title = "Large Change", x = "", y = "")+ theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    geom_vline(xintercept = 0, linetype="dashed",size=0.2)+
    theme(plot.title = element_text(hjust = 0.5, vjust = 0, size = 10))+ theme(aspect.ratio=3/4.25)+ 
    theme(plot.margin = unit(c(0.06,0.06,0.06,0.06), "cm"))+ theme(panel.border = element_rect(size = 0.3))+
    theme(axis.ticks = element_line(size = 0.3))+guides(color=guide_legend(ncol = 1, nrow = 3, keyheight = 0.7, override.aes=list(fill=NA)))+
    theme(legend.position = "bottom")+theme(legend.text = element_text(size = 7))+
    theme(text = element_text(family="Times")) +theme(axis.text = element_text(size = 6))+
    theme(legend.margin=margin(-5, +5, 0, -5))
  
  
  
  ggplot(dataforplot_all) + 
    geom_ribbon(aes(ymin=(sclgauss_all-yact_all)*(-1), ymax=(scrgauss_all-yact_all)*(-1), x=ti, fill="90% CI (out-of-sample uncertainty)"), alpha = 1) +
    geom_line(aes(x=ti, y = (sclgauss_all-yact_all)*(-1), color = "90% CI (out-of-sample uncertainty)", size = "90% CI (out-of-sample uncertainty)")) +
    geom_line(aes(x=ti, y = (scrgauss_all-yact_all)*(-1), color = "90% CI (out-of-sample uncertainty)", size = "90% CI (out-of-sample uncertainty)")) +
    geom_line(aes(y=(yfit_all-yact_all)*(-1), x=ti, colour = "Doppelganger gap (avg.)", size="Doppelganger gap (avg.)"))+
    scale_colour_manual(name='', values=c("Doppelganger gap (avg.)" = "blue", "90% CI (out-of-sample uncertainty)" = "grey95")) +
    scale_fill_manual(name = '',  values=c("Doppelganger gap (avg.)" = "blue", "90% CI (out-of-sample uncertainty)" = "grey95")) +
    scale_size_manual(name = '',  values=c("Doppelganger gap (avg.)" = 0.4, "90% CI (out-of-sample uncertainty)" = 0.4)) +
    theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    scale_x_continuous(breaks=seq(-4,0,4), expand=c(0.02,0.02))+
    # scale_y_continuous(limits = c(-0.30, 0.10), breaks = c(-0.30,-0.25,-0.2,-0.15,-0.1,-0.05,0,0.05,0.1), labels = format(c("-30%","-25%","-20%","-15%","-10%","-5%","0%","+5%","+10%"),nsmall=1), expand=c(0.02,0.02))+ 
    labs(title = "All populists", x = "", y = "")+  theme_bw()+  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    geom_vline(xintercept = 0, linetype="dashed",size=0.2)+ geom_hline(yintercept = 0, linetype="dashed",size=0.2)+
    theme(plot.title = element_text(hjust = 0.5, vjust = 0, size = 10))+ theme(aspect.ratio=3/4.25)+ 
    theme(plot.margin = unit(c(0.06,0.06,0.06,0.06), "cm"))+  theme(panel.border = element_rect(size = 0.3))+
    theme(axis.ticks = element_line(size = 0.3))+ guides(color=guide_legend(keyheight = 0.5, override.aes=list(fill=NA)))+
    theme(axis.ticks = element_line(size = 0.3))+guides(color=guide_legend(ncol = 1, nrow = 2, keyheight = 0.7, override.aes=list(fill=NA)))+
    theme(legend.position = "bottom")+theme(legend.text = element_text(size = 7))+
    theme(text = element_text(family="Times")) + theme(axis.text = element_text(size = 6))+
    theme(legend.margin=margin(-18, +5, 0, -5))  
  