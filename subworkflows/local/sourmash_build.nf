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
  def library = genomes.collate(params.batch_size)

  // We generate sketches of the library for each scaling factor but for all k-mer sizes.
  SOURMASH_SKETCH(
      library
          .combine(scaling_factors)
          // The combinations also remove the list from the `.collate` batch.
          .map { [it[0..-2], it[-1]] }
          // We want the cartesian product with the list of k-mer sizes.
          // Needs `.toList().toList()`, don't ask why ¯\_(ツ)_/¯
          .combine(kmer_sizes.toList().toList())
          // .map { [it[0..-3], it[-2], it[-1]] }
          .tap { log_sketch }
  )

  // Replace file batch list with something shorter for logging.
  log_sketch.map { [['genomes']] + it[1..-1] }
      .dump(tag: 'sketch-library')

  // We have to create a separate index for each scaling factor and each k-mer size.
  // This is required by sourmash for constructing an index.
  SOURMASH_INDEX(
      SOURMASH_SKETCH.out.signatures
          .groupTuple(by: 1)
          // The output was a list of signatures which was then grouped into a list-of-lists.
          // We need a flat list as path input to the next process.
          .map { [it[0].flatten(), it[1]] }
          .combine(kmer_sizes)
          .dump(tag: 'index-library')
          .tap { log_index },
      taxonomy
  )

  // Replace file batch list with something shorter for logging.
  log_index.map { [['signatures']] + it[1..-1] }
      .dump(tag: 'index-library')

  emit:
  database = SOURMASH_INDEX.out.database
}
