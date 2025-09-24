process bcl2fastq {
  label 'bcl2fastq'
  
  input: 
  path(illuminaSamplesheet)

  output:
  path(fastq_list)

  shell:
  
  fastq_list='fastq_list.csv'
  
  template 'bcl2fastq.sh'

}