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
