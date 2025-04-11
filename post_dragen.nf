#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info """\
         P O S T  D R A G E N  P I P E L I N E
         ===================================
         samplesheet  : ${params.samplesheet}
         group        : ${params.group}
         tmpdir       : ${params.tmpdir}
         """
         .stripIndent()
include { structure_and_copystats } from './modules/structure_and_copystats'
include { forcedcalls_inhouse } from './modules/inhouse/forcedcalls_inhouse'
include { preprocess_inhouse } from './modules/inhouse/preprocess_inhouse'
include { coverage } from './modules/coverage'

def find_file(sample) {
    runPrefix=sample.sequencingStartDate + "_" + sample.sequencer + "_" +sample.run + "_" + sample.flowcell
    String path=params.tmpDataDir + "/results/" + runPrefix + "/Analysis/" + sample.externalSampleID
    sample.files = file(path+"/*")
    sample.analysisFolder=params.tmpDataDir + "/results/" + runPrefix + "/Analysis/"
    sample.projectResultsDir=params.tmpDataDir+"/projects/POST_DRAGEN/"+sample.project+"/run01/results/"

    return sample
}

workflow {
  Channel.fromPath(params.samplesheet)
  | splitCsv(header:true)
  | map { find_file(it) }
  | map { samples -> [ samples, samples.files ]}
  | set { ch_input }

  ch_input.collect()
  | structure_and_copystats

  ch_input
  | forcedcalls_inhouse
  | preprocess_inhouse
  | set{ch_processed}
  
  ch_processed
  | coverage
  
}
