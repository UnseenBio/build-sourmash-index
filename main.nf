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


======================================
Genomes:      ${params.input}
Results Path: ${params.outdir}

************************************************************

"""
  def genomes = Channel.fromPath(params.input, checkIfExists: true)
  def taxonomy = params.taxonomy == 'MISSING' ? Channel.fromPath(params.taxonomy) : Channel.fromPath(params.taxonomy, checkIfExists: true)

  SOURMASH_BUILD(genomes, taxonomy)

}