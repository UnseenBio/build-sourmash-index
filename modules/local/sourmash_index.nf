process SOURMASH_INDEX {
    conda (params.enable_conda ? "bioconda::sourmash=4.2.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.2.3--hdfd78af_0':
        'quay.io/biocontainers/sourmash:4.2.3--hdfd78af_0' }"

    input:
    path(signature, stageAs: 'sketches/*')
    path(taxonomy)

    output:
    path(database), emit: database

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "database_k${params.kmer_size}"
    database = taxonomy.name == 'MISSING' ? "${prefix}.sbt.zip" : "${prefix}.lca.json.gz"
    if (taxonomy.name == 'MISSING') {
        """
        ls sketches/*.sig > signatures.txt
    
        sourmash index \\
            $args \\
            --ksize ${params.kmer_size} \\
            --from-file signatures.txt \\
            '${database}'
        """
    } else {
        """
        ls sketches/*.sig > signatures.txt
    
        sourmash lca index \\
            $args \\
            --ksize ${params.kmer_size} \\
            --from-file signatures.txt \\
            '${taxonomy}' \\
            '${database}'
        """
    }
}
