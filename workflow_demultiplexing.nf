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

include { create_illumina_samplesheet } from './modules/inhouse/create_illumina_samplesheet.nf'
include { bcl2fastq } from './modules/inhouse/bcl2fastq.nf'
include { copyInfo } from './modules/inhouse/copyInfo.nf'
include { count_reads } from './modules/inhouse/count_reads.nf'

def split_samples(sample) {
    check_fastq(sample.fastqAvailable)
    return sample
}
def check_fastq(sample){
  if ( sample.fastqAvailable == 'yes'){
    return true
  }
  else{
    return false
  }
}

workflow {
  Channel.fromPath(params.samplesheet)
	| create_illumina_samplesheet
	| set { ch_samplesheet_check }
	
	ch_samplesheet_check 
	| bcl2fastq
	| set{fastq_processed}
	
	fastq_processed
	| copyInfo

	fastq_processed
	| count_reads
}

  