install.packages("devtools")

devtools::install_version(c("tidyverse", 
                            "dplyr", 
                            "kohonen", 
                            "scales", 
                            "lubridate"), 
                          version = c("1.2.1", 
                                      "0.8.0.1", 
                                      "3.0.8", 
                                      "1.0.0",
                                      "1.7.4"))
