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

  main:

  def library = genomes.collate(params.batch_size)

  SOURMASH_SKETCH(library)

  SOURMASH_INDEX(
    SOURMASH_SKETCH.out.signature.collect(),
    taxonomy
  )

  emit:
  database = SOURMASH_INDEX.out.database
}
