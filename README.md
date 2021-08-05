# rsr
Retrieve &amp; tidy data from the [UNHCR Resettlement Statistics Report application](https://rsr.unhcr.org).

### Installation

    remotes::install_github("galalH/rsr")

### Usage

    library(rsr)

The first time you install the package, you need to call `rsr_login()` to initialize your access credentials. `rsr` uses the [`chromote`](https://github.com/rstudio/chromote) package to launch a new tab in any chromium-based browser on your system where you should login to your UNHCR account as usual before returning to your R session and hitting return to continue. This process needs to be done only once after installation, then again any time you update your UNHCR access credentials. See the excellent documentation from sister-package [popdata](https://github.com/PopulationStatistics/popdata/#using-the-popdata-package) for more details on how this works.

Once everything is up and running, you can use any of the convenience functions in the package to access a tidy version of the data from the summary reports produced by the system.

     > rsr_submissions(bureau = "The Americas", year = 2020, month = 5)
     # A tibble: 102 x 6
       asof       coa   coo   cor   unit      n
       <date>     <chr> <chr> <chr> <chr> <dbl>
     1 2020-05-31 CUB   AFG   AUL   C         2
     2 2020-05-31 CUB   AFG   AUL   P         2
     3 2020-05-31 CUB   AFG   FRA   C         2
     4 2020-05-31 CUB   AFG   FRA   P         6
     5 2020-05-31 CUB   AFG   NET   C         0
     6 2020-05-31 CUB   AFG   NET   P         0
     7 2020-05-31 CUB   AFG   NZL   C         2
     8 2020-05-31 CUB   AFG   NZL   P         2
     9 2020-05-31 CUB   AFG   SWE   C         0
    10 2020-05-31 CUB   AFG   SWE   P         0
    # ... with 92 more rows
