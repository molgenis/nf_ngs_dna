#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info """\
         W G S   P I P E L I N E
         ===================================
         samplesheet  : ${params.samplesheet}
         group        : ${params.group}
         tmpdir       : ${params.tmpdir}
         """
         .stripIndent()

include { prepare_fastqlist } from './modules/inhouse/prepare_fastqlist'
include { run_dragen_solo } from './modules/inhouse/run_dragen_solo'
include { create_project_samplesheet } from './modules/inhouse/create_project_samplesheet'

def find_file(sample) {
    sample.barcodeWithDot=sample.barcode.replace("-", ".")
    sample.rawdataName=sample.sequencingStartDate+"_"+sample.sequencer+"_"+sample.run+"_"+sample.flowcell
    return sample
}

workflow {
  Channel.fromPath(params.samplesheet)
  | splitCsv(header:true)
  | map { find_file(it) }
  | map { samples -> [ samples, samples.externalSampleID ]}
  | groupTuple (by: 1)
  | prepare_fastqlist
  | run_dragen_solo
  | set{ch_processed}
  
  ch_processed.collect()
  | create_project_samplesheet
  }