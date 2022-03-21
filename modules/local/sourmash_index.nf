process SOURMASH_INDEX {
    conda (params.enable_conda ? "bioconda::sourmash=4.3.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.3.0--hdfd78af_0':
        'quay.io/biocontainers/sourmash:4.3.0--hdfd78af_0' }"

    input:
    tuple path(signature, stageAs: 'sketches/*'), val(scaling_factor), val(kmer_size)
    path taxonomy

    output:
    path database, emit: database

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "database_s${scaling_factor}_k${kmer_size}"
    database = taxonomy.name == 'MISSING' ? "${prefix}.sbt.zip" : "${prefix}.lca.json.gz"
    if (taxonomy.name == 'MISSING') {
        """
        ls sketches/*.sig > signatures.txt
    
        sourmash index \\
            $args \\
            --scaled ${scaling_factor} \\
            --ksize ${kmer_size} \\
            --from-file signatures.txt \\
            '${database}'
        """
    } else {
        """
        ls sketches/*.sig > signatures.txt
    
        sourmash lca index \\
            $args \\
            --scaled ${scaling_factor} \\
            --ksize ${kmer_size} \\
            --from-file signatures.txt \\
            '${taxonomy}' \\
            '${database}'
        """
    }
}
