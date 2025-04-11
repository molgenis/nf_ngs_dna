#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info """\
         S W G S   P I P E L I N E
         ===================================
         samplesheet  : ${params.samplesheet}
         group        : ${params.group}
         tmpdir       : ${params.tmpdir}
         """
         .stripIndent()

include { structure_and_copystats } from './modules/structure_and_copystats'
include { process_dragen_trendanalysis } from './modules/process_dragen_trendanalysis'
include { preprocess_swgs } from './modules/preprocess_swgs'

def find_file(sample) {
    def batch = sample.gsBatch
    if (sample.gsBatchFolderName != null){
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
  | preprocess_swgs
  
}
