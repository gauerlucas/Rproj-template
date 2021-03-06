# A simple project template for clinical studies.

*Not the best nor the most elegant way, but at least it works for my personal use.*

## This template a nutshell :

-   All data are stored in `data/`
-   All code is in `markdown/`
-   All outputs are generated in `output/`

Check [example/main_doc.html](example/main_doc.html) to get an overview of the end result.

Basic principle : You only work on Rmarkdown notebooks.  
It automatically generates synthetic HTML files to share or archive as a lab notebook.  
The main script to run is found in `markdown/main_doc.rmd` and is self-explanatory.

Mostly based on [R Markdown Cookbook by Yihui Xie, Christophe Dervieux, Emily Riederer](https://bookdown.org/yihui/rmarkdown-cookbook/).

### To do list :

-   [x] Set git
-   [ ] Set `renv` to manage libraries in a better way
-   [ ] Add `ggplot`, `diagrammR` and `tableone` templates

## Proposed workflow

1.  Put all your raw data in `data/`.

2.  Adapt the `markdown/sections/import_raw_data.Rmd` script to your raw data and run it.

3.  Still in the `markdown/sections/` folder, you can adapt `graph_example.Rmd` or `table_example.Rmd` to your data, or create your own Rmarkdown scripts. You can test them in the same Rstudio session using the imported data from 2. .

4.  Open `markdown/main_doc.Rmd` :

    1.  Choose which scripts you want to run in "Ordered list of currently used scripts".

    2.  Knit the document : it will run all choosed child scripts, generate figures, processed data and a synthetic HTML file.

5.  For the next work sessions, you can open `markdown/main_doc.Rmd` and run it up to the "dev" chunk : this chunk will reload all your previous work in your environment, always using up-to-date data. Then you can start to write new scripts, save them in `markdown/sections`, add them to `main_doc.Rmd` if they are working properly etc.

### Memo : How to link to Github from existing folder

1.  Open `template-proj.Rproj`, then run `usethis::use_git()`.
2.  Create an empty `project-name` GitHub repo.
3.  Open a terminal and `cd` to `template-proj.Rproj` place.
4.  Run `git push` commands :

```{bash eval=FALSE}
git remote add origin git@github.com:Username/project-name.git
git push -u origin master
```

## Detailed file structure

In `data/` : original raw data (untouched).

-   `sub-XXX/` : a data folder for every patient

    -   `agenda_mig.xlsx` : example of migraine agenda of patient "sub-XXX"
    -   `agenda_mig_vars.xlsx` : description of used variables (same for all patients)

-   `subject_db.xlsx` : list of all patients and some demographic features

-   `subject_db_var_description.xlsx` : description of variables used in `patient.xlsx` table.

In `markdown/` :

-   `raw_scripts/extracted/` : R scripts automatically extracted from Markdown documents in `markdown/sections`.
-   `sections/` : Markdown scripts used to process data.
-   `inserts/` : objects to import (*ie.* images generated elsewhere).
-   `main_doc.Rmd` : Main working/synthetic document and HTML version to share and review.
-   `references.bib` : bibliography file used in this document.
-   `vancouver.csl`: citation format used in this document (Vancouver numeric).

In `output/` (this folder is automatically created when running code in this document) :

-   `sub-xxx/` : contains intermediate files automatically saved during processing.
-   `figs/` : figures generated during the processing.
-   `complete_extracted_table.csv` : summary across all patients (Excel-friendly CSV).
-   `complete_extracted_table.RData` : summary across all patients (RData file).

## Libraries used in this project

```{r message=FALSE, warning=FALSE}
library(tidyverse)
library(readxl) # Installed with tidyverse but loads separately
library(hablar) # To easily assign types of variables after data importation.
library(lubridate) # Installed with tidyverse but loads separately
library(zoo) # use for rolling average easy computation with rollapplyr
library(gtsummary) # Easy summary tables
library(hrbrthemes) # Nice themes for ggplot
```

Synthetic HTML files are knitted using `bookdown` ,and with the `downcute` template from `rmdformats`.
