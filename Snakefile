## Workflow - Angrist + Krueger QJE 1991
##
## authors: @lachlandeer
##

# --- Importing Configuration Files --- #

### inside this file are all the paths we use pre-written up - see below for how to use it
configfile: "config.yaml"

# --- Dictionaries --- #

FIGS            = glob_wildcards(config["src_figures"] + "{iFile}.R").iFile
FIXED_EFFECTS   = ["no_fixed_effects", "fixed_effects"]
INSTRUMENT_SPEC = glob_wildcards(config["src_model_specs"] + 
                                    "instrument_{iInst}.json",
                                ).iInst

# --- EVERYTHING --- #

rule all:
   input:
        paper  = config["out_paper"] + "paper.pdf",
        slides = config["out_slides"] + "slides.pdf"


# --- SLIDES --- #
rule slides:
    input:
        rmarkdown = config["src_slides"] + "slides.Rmd",
        script    = config["src_lib"] + "knit_rmd.R",
        figures   =  expand(config["out_figures"] + "{iFigure}.pdf", 
                        iFigure = FIGS),
        table     = config["out_tables"] + "regression_table.tex",
    output:
        pdf = config["out_slides"] + "slides.pdf",
    shell: 
        "Rscript {input.script} {input.rmarkdown} {output.pdf}"

# --- PAPER --- #

rule paper:
    input:
        rmarkdown = config["src_paper"] + "paper.Rmd",
        script    = config["src_lib"] + "knit_rmd.R",
        figures   =  expand(config["out_figures"] + "{iFigure}.pdf", 
                        iFigure = FIGS),
        table     = config["out_tables"] + "regression_table.tex",
    output:
        pdf = config["out_paper"] +"paper.pdf",
    shell: 
        "Rscript {input.script} {input.rmarkdown} {output.pdf}"

# --- TABLE --- #

rule make_table:
    input:
        script  = config["src_tables"] + "regression_table.R",
        ols_res = expand(config["out_analysis"] + "ols_{iFixedEffect}.Rds",
                        iFixedEffect = FIXED_EFFECTS),
        iv_res  = expand(config["out_analysis"] + "iv_{iInstrument}.{iFixedEffect}.Rds",
                        iInstrument  = INSTRUMENT_SPEC,
                        iFixedEffect = FIXED_EFFECTS)
    output:
        table = config["out_tables"] + "regression_table.tex"
    params:
        directory = config["out_analysis"]
    shell:
        "Rscript {input.script} \
            --filepath {params.directory} \
            --out {output.table}"

# --- MODELS --- #
rule run_models:
    input:
        ols = expand(config["out_analysis"] + "ols_{iFixedEffect}.Rds",
                        iFixedEffect = FIXED_EFFECTS),
        iv = expand(config["out_analysis"] + "iv_{iInstrument}.{iFixedEffect}.Rds",
                        iInstrument  = INSTRUMENT_SPEC,
                        iFixedEffect = FIXED_EFFECTS)

rule iv:
    input:
        script       = config["src_analysis"] + "estimate_iv.R",
        data         = config["out_data"] + "angrist_krueger.csv", 
        equation     = config["src_model_specs"] + "estimating_equation.json",
        fixedEffects = config["src_model_specs"] + "{iFixedEffect}.json",
        inst         = config["src_model_specs"] + "instrument_{iInstrument}.json",
    output:
        model = config["out_analysis"] + "iv_{iInstrument}.{iFixedEffect}.Rds"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --model {input.equation} \
            --fixedEffects {input.fixedEffects} \
            --instruments {input.inst} \
            --out {output.model}"

rule ols:
    input:
        script       = config["src_analysis"] + "estimate_ols.R",
        data         = config["out_data"] + "angrist_krueger.csv", 
        equation     = config["src_model_specs"] + "estimating_equation.json",
        fixedEffects = config["src_model_specs"] +"{iFixedEffect}.json",
    output:
        model = config["out_analysis"] + "ols_{iFixedEffect}.Rds"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --model {input.equation} \
            --fixedEffects {input.fixedEffects} \
            --out {output.model}"

# --- FIGURES --- #

rule make_figs:
    input:
        figs = expand("out/figures/{iFigure}.pdf", 
                        iFigure = FIGS)

rule figs:
    input:
        script = config["src_figures"] + "{iFigure}.R",
        data   = config["out_data"] + "cohort_summary.csv",
    output:
        pdf = config["out_figures"] + "{iFigure}.pdf",
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.pdf}"
 

rule cohort_summary:
    input:
        script = config["src_data_mgt"] + "cohort_summary.R",
        data   = config["out_data"] + "angrist_krueger.csv" 
    output:
        csv = config["out_data"] + "cohort_summary.csv"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.csv}"

rule gen_reg_vars:
    input:
        script = config["src_data_mgt"] + "gen_reg_vars.R",
        data   = config["out_data"] + "angrist_krueger_1991.zip"   
    output:
        csv = config["out_data"] + "angrist_krueger.csv"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.csv}"

rule download_data:
    input:
        script = config["src_data_mgt"] + "download_data.R"
    output:
        data =  config["out_data"] + "angrist_krueger_1991.zip"
    params:
        url = "http://economics.mit.edu/files/397"
    shell:
        "Rscript {input.script} \
            --url {params.url} \
            --dest {output.data}"

rule clean:
    shell:
        "rm -r out/*"

rule dag:
    input:
        "Snakefile"
    output:
        "dag.pdf"
    shell:
        "snakemake --dag | dot -Tpdf > {output}"

rule filegraph:
    input:
        "Snakefile"
    output:
        "filegraph.pdf"
    shell:
        "snakemake --filegraph | dot -Tpdf > {output}"

rule rulegraph:
    input:
        "Snakefile"
    output:
        "rulegraph.pdf"
    shell:
        "snakemake --rulegraph | dot -Tpdf > {output}"
