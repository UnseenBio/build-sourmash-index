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
      library.combine(scaling_factors)
          .combine([kmer_sizes.collect()])
          .map { [it[0..-3)], it[-2], it[-1]] }
          .tap { log_sketch }
          // .map { [it[0..(-kmer_sizes.size() - 2)], it[-kmer_sizes.size() - 1], it[(-kmer_sizes.size())..-1]] }
  )

  log_sketch.map { [['...']] + it[1..-1] }.dump(tag: 'sketch-library')

  // We have to create a separate index for each scaling factor and each k-mer size.
  SOURMASH_SKETCH.out.signatures
      .groupTuple(by: 1)
      .combine(kmer_sizes)
      .dump(tag: 'index-library')
  // SOURMASH_INDEX(
    // SOURMASH_SKETCH.out.signatures.collect()
      // .combine(scaling_factors)
      // .combine(kmer_sizes),
    // taxonomy
  // )

  // emit:
  // database = SOURMASH_INDEX.out.database
}
