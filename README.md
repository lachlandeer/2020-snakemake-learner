# Replicate MHE Table 4.1.1 and Figure 4.1.1

## What this repo does

We replicate Table 4.1.1 and Figure 4.1.1 from Mostly Harmless Econometrics using a reproducible research workflow.

Our weapons of choice are:

* `Snakemake` to manage the build and dependencies
* `R` for statistical analysis

## How to Build this repo

If you have Snakemake and R installed, navigate your terminal to this directory.

### Installing Missing R packages

To ensure all R libraries are installed, type

```
snakemake install_packages
```

into a your terminal and press `RETURN` - this will install all packages that are used in `.R` scripts.

If you modify the packages used in this repo, you should rerun this command to store package updates in the `REQUIREMENTS.txt`.

You also might need to install Rmarkdown and knitr so that you get the pdfs of the paper and slides to build, type

```
snakemake install_rmd
```

into a your terminal and press `RETURN`.

**NOTE**: This method of managing packages is a little convoluted. 
If you want a better package management system, checkout the package `Renv` - it's what I use in my real world workflow.

### Building the Output

The final output of this project is a pdf of a paper and a slide deck. 

Type:

```
snakemake all
```

into a your terminal and press `RETURN`. When Snakemake build successfully you will have two pdf documents in your project's main directory

See [`HELP.txt`](HELP.txt) for explanation of what the Snakemake Rules are doing.

## Visualizing the Snakemake Workflow

Snakemake provides three visualizations of how the different rules piece together to form the output (or more technically, how it builds the first rule that it sees in the Snakefile).

To see these visualizations as pdfs (using rules we wrote so we dont have to rememeber messy syntax):

1. Rulegraph: How the rules piece together:

```
snakemake rulegraph
```

2. DAG: the directed acyclic graph it executes (note this fleshes out any wildcard expansion)

```
snakemake dag
```

3. Filegraph: The input and output files used by each rule.

```
snakemake filegraph
```

Notice the output of the rule as a pdf has the same name as the rule, i.e `snakemake dag` produces `dag.pdf` etc.

**NOTE:** If these rules don't build for you, its likely you are missing the `graphviz` library on your system. 
Install with either `snakemake install_graphviz` or `snakemake install_graphviz_mac`.

## Install instructions for R and Snakemake

### Installing `R`

* Install the latest version of `R` by following the instructions
  [here](https://pp4rs.github.io/installation-guide/r/).
    * You can ignore the RStudio instructions for the purpose of this project.

### Installing `Snakemake`

This project uses `Snakemake` to execute our research workflow.
You can install snakemake as follows:
* Install Snakemake from the command line (needs pip, and Python)
    ```
    pip install snakemake
    ```
    * If you haven't got Python installed click [here](https://pp4rs.github.io/installation-guide/python/) for instructions

* Windows and old Mac OSX users: you may need to manually install the `datrie` package if you are getting errors. Using conda, this seems to work best:

    ```
    conda install datrie
    ```

## Suggested Citation:

Deer, Lachlan, 2019. "Replication of Angrist and Krueger (1991) : Table 4.1.1 and Figure 4.1.1 from Mostly Harmless Econometrics.
