#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info """\
         D R A G E N   P I P E L I N E
         ===================================
         samplesheet  : ${params.samplesheet}
         group        : ${params.group}
         tmpdir       : ${params.tmpdir}
         cluster      : ${params.cluster}
         """
         .stripIndent()

include { run_dragen_solo } from './modules/inhouse/run_dragen_solo.nf'

def split_samples(sample) {
    sample.projectResultsDir=params.tmpDataDir+"/projects/NGS_DNA/"

    return sample
}

workflow {
  Channel.fromPath(params.samplesheet)
  | prepare_fastqlist
  Channel.fromPath(params.samplesheet)
  | run_dragen_solo

}
