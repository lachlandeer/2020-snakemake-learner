FIGS = glob_wildcards("src/figures/{iFile}.R").iFile
FIXED_EFFECTS = ["no_fixed_effects", "fixed_effects"]
INSTRUMENT_SPEC = glob_wildcards("src/model-specs/instrument_{iInst}.json",
                                ).iInst
print(INSTRUMENT_SPEC)

# --- MODELS --- #
rule run_models:
    input:
        ols = expand("out/analysis/ols_{iFixedEffect}.Rds",
                        iFixedEffect = FIXED_EFFECTS),
        iv = expand("out/analysis/iv_{iInstrument}.Rds",
                        iInstrument = INSTRUMENT_SPEC),

rule iv:
    input:
        script       = "src/analysis/estimate_iv.R",
        data         = "out/data/angrist_krueger.csv", 
        equation     = "src/model-specs/estimating_equation.json",
        fixedEffects = "src/model-specs/fixed_effects.json",
        inst         = "src/model-specs/instrument_{iInstrument}.json",
    output:
        model = "out/analysis/iv_{iInstrument}.Rds"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --model {input.equation} \
            --fixedEffects {input.fixedEffects} \
            --instruments {input.inst} \
            --out {output.model}"

rule ols:
    input:
        script       = "src/analysis/estimate_ols.R",
        data         = "out/data/angrist_krueger.csv", 
        equation     = "src/model-specs/estimating_equation.json",
        fixedEffects = "src/model-specs/{iFixedEffect}.json",
    output:
        model = "out/analysis/ols_{iFixedEffect}.Rds"
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
        script = "src/figures/{iFigure}.R",
        data   = "out/data/cohort_summary.csv",
    output:
        pdf = "out/figures/{iFigure}.pdf",
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.pdf}"
 

rule cohort_summary:
    input:
        script = "src/data-management/cohort_summary.R",
        data   = "out/data/angrist_krueger.csv" 
    output:
        csv = "out/data/cohort_summary.csv"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.csv}"

rule gen_reg_vars:
    input:
        script = "src/data-management/gen_reg_vars.R",
        data   = "out/data/angrist_krueger_1991.zip"   
    output:
        csv = "out/data/angrist_krueger.csv"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.csv}"

rule download_data:
    input:
        script = "src/data-management/download_data.R"
    output:
        data = "out/data/angrist_krueger_1991.zip"
    params:
        url = "http://economics.mit.edu/files/397"
    shell:
        "Rscript {input.script} \
            --url {params.url} \
            --dest {output.data}"

rule clean:
    shell:
        "rm -r out/*"

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