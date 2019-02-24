## Workflow - Replicate MHE Table 4.1.1
##
## authors: @lachlandeer
##

from pathlib import Path

# --- Importing Configuration Files --- #

configfile: "config.yaml"

# --- Dictionaries --- #

FIGS = glob_wildcards(config["src_figures"] + "{iFile}.R").iFile
print(FIGS)

# --- Build Rules --- #

rule all:
    input:
        paper = config["out_paper"] + "paper.pdf"
    output:
        paper = Path("pp4rs_assignment.pdf")
    shell:
        "rm -f Rplots.pdf && cp {input.paper} {output.paper}"

## paper: builds Rmd to pdf
# Note: this uses a simpler command line parsing strategy
rule paper:
    input:
        paper = config["src_paper"] + "paper.Rmd",
        runner = config["src_lib"] + "knit_rmd.R",
        figures = expand(config["out_figures"] + "{iFigure}.pdf",
                        iFigure = FIGS),
    output:
        pdf = Path(config["out_paper"] + "paper.pdf")
    log:
        config["log"] + "paper/paper.Rout"
    shell:
        "Rscript {input.runner} {input.paper} {output.pdf} \
            > {log} 2>&1"

rule create_figure:
    input:
        script = config["src_figures"] + "{iFigure}.R",
        data   = config["out_data"] + "cohort_summary.csv",
    output:
        pdf = Path(config["out_figures"] + "{iFigure}.pdf"),
    log:
        config["log"] + "figures/{iFigure}.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.pdf} \
            > {log} 2>&1"

rule gen_cohort_sum:
    input:
        script = config["src_data_mgt"] + "cohort_summary.R",
        data   = config["out_data"] + "angrist_krueger.csv",
    output:
        data = Path(config["out_data"] + "cohort_summary.csv"),
    log:
        config["log"] + "data-mgt/cohort_summary.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.data} \
            > {log} 2>&1"

rule gen_reg_vars:
    input:
        script      = config["src_data_mgt"] + "gen_reg_vars.R",
        zip_archive = config["src_data"] + "angrist_krueger_1991.zip"
    output:
        data = Path(config["out_data"] + "angrist_krueger.csv")
    log:
        config["log"] + "data-mgt/gen_reg_vars.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.zip_archive} \
            --out {output.data} \
            > {log} 2>&1"

rule download_data:
    input:
        script = config["src_data_mgt"] + "download_data.R",
    output:
        data = Path(config["src_data"] + "angrist_krueger_1991.zip"),
    params:
        url = "http://economics.mit.edu/files/397",
    log:
        config["log"] + "data-mgt/download_data.Rout"
    shell:
        "Rscript {input.script} \
            --url {params.url} \
            --dest {output.data} \
            > {log} 2>&1"

# --- Clean Rules --- #
## clean              : removes all content from out/ directory
rule clean:
    shell:
        "rm -rf out/*"

# --- Help Rules --- #
## help               : prints help comments for Snakefile
rule help:
    input:
        main     = "Snakefile",
    output: "HELP.txt"
    shell:
        "find . -type f -name 'Snakefile' | tac | xargs sed -n 's/^##//p' \
            > {output}"
