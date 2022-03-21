#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/* ############################################################################
 * Dependencies from sub modules.
 * ############################################################################
 */

include { SOURMASH_BUILD } from './subworkflows/local/sourmash_build'

/* ############################################################################
 * Define an implicit workflow that only runs when this is the main nextflow
 * pipeline called.
 * ############################################################################
 */

workflow {
  log.info """
************************************************************

Build Sourmash Index
====================
Genomes:         ${params.input}
Taxonomy:        ${params.taxonomy == 'MISSING' ? 'Not provided' : params.taxonomy}
Scaling Factors: ${params.scaling_factor}
K-Mer Sizes:     ${params.kmer_sizes}
Batch Size:      ${params.batch_size}
Results Path:    ${params.outdir}

************************************************************

"""
  def genomes = Channel.fromPath(params.input, checkIfExists: true)
  def taxonomy = params.taxonomy == 'MISSING' ? Channel.fromPath(params.taxonomy) : Channel.fromPath(params.taxonomy, checkIfExists: true)
  def kmer_sizes = Channel.fromList(params.kmer_sizes.split(','))
  def scaling_factors = Channel.fromList(params.scaling_factors.split(','))

  SOURMASH_BUILD(genomes, taxonomy, kmer_sizes, scaling_factors)

}