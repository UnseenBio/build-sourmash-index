process SOURMASH_SKETCH {
    conda (params.enable_conda ? "bioconda::sourmash=4.3.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.3.0--hdfd78af_0':
        'quay.io/biocontainers/sourmash:4.3.0--hdfd78af_0' }"

    input:
    path(library, stageAs: 'library/*')
    val scaling_factor
    val kmer_sizes

    output:
    path("sketches/*.sig"), emit: signatures

    script:
    // def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: 'dna'
    def kmers = kmer_sizes.collect { "k=${it}" }.join(',')
    def arguments="scaled=${scaling_factor},${kmers}"
    """
    ls library/* > library.txt
    mkdir sketches

    sourmash sketch \\
        $args \\
        --param-string '${arguments}' \\
        --from-file library.txt \\
        --outdir sketches \\
        --name-from-first

    """
}
