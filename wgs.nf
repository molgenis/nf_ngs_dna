#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info """\
         T E S T - N F   P I P E L I N E
         ===================================
         samplesheet  : ${params.samplesheet}
         group        : ${params.group}
         tmpdir       : ${params.tmpdir}
         """
         .stripIndent()

include { structure_and_copystats } from './modules/structure_and_copystats'
include { process_dragen_trendanalysis } from './modules/process_dragen_trendanalysis'
include { preprocess } from './modules/preprocess'
include { capture_and_reheader } from './modules/capture_and_reheader'
include { forcedcalls } from './modules/forcedcalls'
include { coverage } from './modules/coverage'

def find_file(sample) {
    batch=sample.gsBatch
    if (sample.gsBatchFolderName != "null"){
      batch=sample.gsBatchFolderName
    }
    String path=params.tmpDataDir + batch + "/Analysis/" + sample.GS_ID + "-" + sample.project + "-" + sample.sampleProcessStepID
    sample.files = file(path+"/*")

    sample.analysisFolder=params.tmpDataDir + batch + "/Analysis/"
    sample.projectResultsDir=params.tmpDataDir+"/projects/NGS_DNA/"+sample.project+"/run01/results/"
    sample.combinedIdentifier= file(path).getBaseName()

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
  | process_dragen_trendanalysis
  
  ch_input
  | forcedcalls
  | preprocess
  | set{ch_processed}

  ch_processed
  | capture_and_reheader
  
  ch_processed
  | coverage
}
