rule make_figs:
    input:
        fig_1 = "out/figures/earnings.pdf",
        fig_2 = "out/figures/education.pdf"

rule earnings_by_cohort:
    input:
        script = "src/figures/earnings_by_cohort.R",
        data   = "out/data/cohort_summary.csv"
    output:
        pdf = "out/figures/earnings_by_cohort.pdf"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out  {output.pdf}"

rule education_by_cohort:
    input:
        script = "src/figures/education_by_cohort.R",
        data   = "out/data/cohort_summary.csv"
    output:
        pdf = "out/figures/education_by_cohort.pdf"
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