#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*******************************************************************************
 * Include dependencies.
 ******************************************************************************/

include { SOURMASH_SKETCH } from '../../modules/local/sourmash_sketch'
include { SOURMASH_INDEX } from '../../modules/local/sourmash_index'

/*******************************************************************************
 * Define sub-workflow.
 ******************************************************************************/

workflow SOURMASH_BUILD {
    take:
    genomes
    taxonomy
    kmer_sizes
    scaling_factors
  
    main:
    /* Let sourmash sketch `batch_size` signatures at a time.
    * This is a compromise between sourmash being single threaded and the overhead
    * of starting a separate process (container) for each batch.
    */
    def sketch = genomes.collate(params.batch_size)  // [[genomes]]
        .combine(scaling_factors)  // [genomes, factor]
        // The combinations also remove the list from the `.collate` batch.
        // We want that batch as a path input.
        .map { [it.take(it.size() - 1), it.last()] }  // [[genomes], factor]
        // We want the cartesian product with the list of k-mer sizes.
        // Needs `.toList().toList()`, don't ask why ¯\_(ツ)_/¯
        .combine(kmer_sizes.toList().toList())  // [[genomes], factor, [kmer]]
  
    // Replace file batch list with something shorter for logging.
    sketch.map { [['genomes']] + it.tail() }
        .dump(tag: 'sketch-batch')
  
    // We generate sketches of the library for each scaling factor but for all k-mer sizes.
    SOURMASH_SKETCH(sketch)
  
    def index = SOURMASH_SKETCH.out.signatures  // [[signatures], factor]
        .groupTuple(by: 1)  // [[[signatures]], factor]
        // The output was a list of signatures which was then grouped into a list-of-lists.
        // We need a flat list as path input to the next process.
        .map { [it.head().flatten(), it.tail()] }  // [[signatures], factor]
        .combine(kmer_sizes)  // [[signatures], factor, kmer]
  
    // Replace file batch list with something shorter for logging.
    index.map { [['signatures']] + it.tail() }
        .dump(tag: 'index-library')

    // We have to create a separate index for each scaling factor and each k-mer size.
    // This is required by sourmash for constructing an index.
    SOURMASH_INDEX(index, taxonomy)
  
    emit:
    database = SOURMASH_INDEX.out.database
}
