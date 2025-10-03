process bcl2fastq {
  label 'bcl2fastq'
  
  input: 
  path(illuminaSamplesheet)

  output:
  path(fastq_list)

  shell:
  
  template 'bcl2fastq.sh'

}