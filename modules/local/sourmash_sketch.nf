process SOURMASH_SKETCH {
    conda (params.enable_conda ? "bioconda::sourmash=4.2.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.2.3--hdfd78af_0':
        'quay.io/biocontainers/sourmash:4.2.3--hdfd78af_0' }"

    input:
    path(library, stageAs: 'library/*')

    output:
    path("sketches/*.sig"), emit: signature

    script:
    // def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: 'dna'
    """
    ls library/* > library.txt
    mkdir sketches

    sourmash sketch \\
        $args \\
        --param-string 'scaled=${params.scaling_factor},k=${params.kmer_size}' \\
        --from-file library.txt \\
        --outdir sketches \\
        --name-from-first

    """
}
